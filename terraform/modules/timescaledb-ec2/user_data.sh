#!/bin/bash
# ============================================================================
# TimescaleDB EC2 Bootstrap Script
# ============================================================================
# This script runs on first boot to configure the EC2 instance with:
# - Docker + Docker Compose
# - EBS volume mounting
# - TimescaleDB container
# - CloudWatch agent (optional)
# - Automated restart on spot interruption
# ============================================================================

set -euo pipefail

# ============================================================================
# Configuration (injected by Terraform)
# ============================================================================

VOLUME_DEVICE="${volume_device_name}"       # /dev/sdf
MOUNT_POINT="${mount_point}"                # /mnt/timescaledb-data
POSTGRES_PASSWORD="${postgres_password}"
DATABASE_NAME="${database_name}"
POSTGRES_VERSION="${postgres_version}"
TIMESCALEDB_IMAGE="${timescaledb_image}"
ENABLE_MONITORING="${enable_monitoring}"

LOG_FILE="/var/log/timescaledb-setup.log"

# ============================================================================
# Logging Function
# ============================================================================

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Starting TimescaleDB setup..."

# ============================================================================
# System Updates
# ============================================================================

log "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq

# Install essential packages
apt-get install -y -qq \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  jq \
  wget \
  unzip \
  nvme-cli

log "System packages updated"

# ============================================================================
# Install Docker
# ============================================================================

log "Installing Docker..."

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker service
systemctl enable docker
systemctl start docker

log "Docker installed: $(docker --version)"

# ============================================================================
# Mount EBS Volume
# ============================================================================

log "Configuring EBS volume..."

# Wait for EBS volume to be attached (up to 60 seconds)
WAIT_COUNT=0
while [ ! -e "$VOLUME_DEVICE" ] && [ $WAIT_COUNT -lt 60 ]; do
  log "Waiting for EBS volume $VOLUME_DEVICE... ($WAIT_COUNT/60)"
  sleep 1
  WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ ! -e "$VOLUME_DEVICE" ]; then
  log "ERROR: EBS volume $VOLUME_DEVICE not found after 60 seconds"
  exit 1
fi

# Identify the actual device name (NVMe devices have different naming)
REAL_DEVICE=$(readlink -f "$VOLUME_DEVICE" || echo "$VOLUME_DEVICE")
log "EBS volume detected: $REAL_DEVICE"

# Check if volume is already formatted
if ! blkid "$REAL_DEVICE" > /dev/null 2>&1; then
  log "Formatting EBS volume as ext4..."
  mkfs.ext4 -F "$REAL_DEVICE"
else
  log "EBS volume already formatted: $(blkid -s TYPE -o value "$REAL_DEVICE")"
fi

# Create mount point
mkdir -p "$MOUNT_POINT"

# Mount the volume
log "Mounting EBS volume to $MOUNT_POINT..."
mount "$REAL_DEVICE" "$MOUNT_POINT"

# Add to /etc/fstab for auto-mount on reboot
VOLUME_UUID=$(blkid -s UUID -o value "$REAL_DEVICE")
if ! grep -q "$VOLUME_UUID" /etc/fstab; then
  echo "UUID=$VOLUME_UUID $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab
  log "Added to /etc/fstab: UUID=$VOLUME_UUID"
fi

# Set permissions
mkdir -p "$MOUNT_POINT/pgdata"
chown -R 999:999 "$MOUNT_POINT/pgdata"  # PostgreSQL UID/GID in Docker
chmod 700 "$MOUNT_POINT/pgdata"

log "EBS volume mounted successfully"

# ============================================================================
# Create Docker Compose Configuration
# ============================================================================

log "Creating Docker Compose configuration..."

cat > /opt/docker-compose.yml <<EOF
version: '3.8'

services:
  timescaledb:
    image: $TIMESCALEDB_IMAGE
    container_name: timescaledb
    restart: unless-stopped

    environment:
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_DB: $DATABASE_NAME
      POSTGRES_USER: postgres
      TIMESCALEDB_TELEMETRY: 'off'

      # Performance tuning (adjust based on instance size)
      # For t4g.micro (1 vCPU, 1 GB RAM):
      POSTGRES_SHARED_BUFFERS: '256MB'
      POSTGRES_EFFECTIVE_CACHE_SIZE: '768MB'
      POSTGRES_WORK_MEM: '8MB'
      POSTGRES_MAINTENANCE_WORK_MEM: '64MB'
      POSTGRES_MAX_CONNECTIONS: '100'

      # WAL settings (for point-in-time recovery)
      POSTGRES_WAL_LEVEL: 'replica'
      POSTGRES_MAX_WAL_SENDERS: '3'
      POSTGRES_WAL_KEEP_SIZE: '64'

    volumes:
      - $MOUNT_POINT/pgdata:/var/lib/postgresql/data
      - $MOUNT_POINT/backups:/backups  # For manual pg_dump backups

    ports:
      - "5432:5432"

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

    # Resource limits (prevent runaway queries)
    mem_limit: 800m  # Leave 200MB for OS on t4g.micro
    cpus: 0.9

volumes:
  timescaledb-data:
    driver: local
EOF

log "Docker Compose configuration created at /opt/docker-compose.yml"

# ============================================================================
# Start TimescaleDB Container
# ============================================================================

log "Starting TimescaleDB container..."

cd /opt
docker compose up -d

# Wait for PostgreSQL to be ready
log "Waiting for PostgreSQL to be ready..."
WAIT_COUNT=0
while ! docker exec timescaledb pg_isready -U postgres > /dev/null 2>&1 && [ $WAIT_COUNT -lt 60 ]; do
  log "Waiting for PostgreSQL... ($WAIT_COUNT/60)"
  sleep 2
  WAIT_COUNT=$((WAIT_COUNT + 2))
done

if ! docker exec timescaledb pg_isready -U postgres > /dev/null 2>&1; then
  log "ERROR: PostgreSQL did not start within 60 seconds"
  docker logs timescaledb | tee -a "$LOG_FILE"
  exit 1
fi

log "TimescaleDB is ready!"

# ============================================================================
# Initialize Database
# ============================================================================

log "Initializing database..."

# Check if TimescaleDB extension already exists
if docker exec timescaledb psql -U postgres -d "$DATABASE_NAME" -tAc "SELECT 1 FROM pg_extension WHERE extname='timescaledb'" | grep -q 1; then
  log "TimescaleDB extension already installed"
else
  log "Installing TimescaleDB extension..."
  docker exec timescaledb psql -U postgres -d "$DATABASE_NAME" -c "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;"

  # Verify installation
  TIMESCALEDB_VERSION=$(docker exec timescaledb psql -U postgres -d "$DATABASE_NAME" -tAc "SELECT extversion FROM pg_extension WHERE extname='timescaledb'")
  log "TimescaleDB extension installed: version $TIMESCALEDB_VERSION"
fi

# Create initial schema (if migrations directory exists)
if [ -d "/opt/migrations" ]; then
  log "Running database migrations..."
  for migration in /opt/migrations/*.sql; do
    if [ -f "$migration" ]; then
      log "Applying migration: $(basename "$migration")"
      docker exec -i timescaledb psql -U postgres -d "$DATABASE_NAME" < "$migration"
    fi
  done
fi

log "Database initialization complete"

# ============================================================================
# Configure Systemd Service (Auto-restart on Reboot)
# ============================================================================

log "Creating systemd service..."

cat > /etc/systemd/system/timescaledb.service <<EOF
[Unit]
Description=TimescaleDB Docker Container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable timescaledb.service

log "Systemd service created and enabled"

# ============================================================================
# Configure CloudWatch Agent (Optional)
# ============================================================================

if [ "$ENABLE_MONITORING" = "true" ]; then
  log "Installing CloudWatch agent..."

  wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
  dpkg -i -E ./amazon-cloudwatch-agent.deb
  rm amazon-cloudwatch-agent.deb

  # Create CloudWatch agent configuration
  cat > /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "namespace": "Lighthouse/TimescaleDB",
    "metrics_collected": {
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DiskUsedPercent",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "$MOUNT_POINT"
        ]
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MemoryUsedPercent",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/timescaledb-setup.log",
            "log_group_name": "/lighthouse/timescaledb/setup",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/lighthouse/timescaledb/syslog",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

  # Start CloudWatch agent
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json

  log "CloudWatch agent installed and started"
fi

# ============================================================================
# Spot Instance Interruption Handler (Optional)
# ============================================================================

log "Configuring spot instance interruption handler..."

cat > /usr/local/bin/spot-instance-handler.sh <<'EOF'
#!/bin/bash
# Monitor EC2 instance metadata for spot interruption notice
# If detected, gracefully stop PostgreSQL before termination

while true; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://169.254.169.254/latest/meta-data/spot/instance-action)

  if [ "$HTTP_CODE" -eq 200 ]; then
    echo "[$(date)] Spot instance interruption detected! Stopping PostgreSQL gracefully..."

    # Stop PostgreSQL cleanly (30 second shutdown timeout)
    docker exec timescaledb pg_ctl stop -m fast -t 30 || true

    # Stop container
    docker stop timescaledb || true

    echo "[$(date)] PostgreSQL stopped. Instance will terminate in ~2 minutes."
    exit 0
  fi

  sleep 5
done
EOF

chmod +x /usr/local/bin/spot-instance-handler.sh

# Create systemd service for spot handler
cat > /etc/systemd/system/spot-instance-handler.service <<EOF
[Unit]
Description=EC2 Spot Instance Interruption Handler
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/spot-instance-handler.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable spot-instance-handler.service
systemctl start spot-instance-handler.service

log "Spot instance interruption handler configured"

# ============================================================================
# Create Backup Script
# ============================================================================

log "Creating backup script..."

cat > /usr/local/bin/backup-timescaledb.sh <<EOF
#!/bin/bash
# Manual backup script (supplements automated EBS snapshots)

set -euo pipefail

BACKUP_DIR="$MOUNT_POINT/backups"
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$MOUNT_POINT/backups/lighthouse_\$TIMESTAMP.sql.gz"

mkdir -p "\$BACKUP_DIR"

echo "[$(date)] Starting PostgreSQL backup..."

# Create compressed backup
docker exec timescaledb pg_dump -U postgres -d $DATABASE_NAME | gzip > "\$BACKUP_FILE"

echo "[$(date)] Backup complete: \$BACKUP_FILE"
echo "[$(date)] Size: \$(du -h "\$BACKUP_FILE" | cut -f1)"

# Delete backups older than 7 days (keep weekly backups)
find "\$BACKUP_DIR" -name "lighthouse_*.sql.gz" -mtime +7 -delete

# Optional: Upload to S3 (uncomment if backup_s3_bucket is configured)
# aws s3 cp "\$BACKUP_FILE" s3://YOUR_BUCKET/backups/timescaledb/

echo "[$(date)] Backup cleanup complete"
EOF

chmod +x /usr/local/bin/backup-timescaledb.sh

# Create weekly cron job for logical backups
cat > /etc/cron.d/timescaledb-backup <<EOF
# Weekly logical backup (supplements daily EBS snapshots)
0 3 * * 0 root /usr/local/bin/backup-timescaledb.sh >> /var/log/timescaledb-backup.log 2>&1
EOF

log "Backup script created: /usr/local/bin/backup-timescaledb.sh"

# ============================================================================
# Final Health Check
# ============================================================================

log "Performing final health check..."

# Check Docker is running
if ! systemctl is-active --quiet docker; then
  log "ERROR: Docker is not running"
  exit 1
fi

# Check TimescaleDB container is running
if ! docker ps | grep -q timescaledb; then
  log "ERROR: TimescaleDB container is not running"
  docker ps -a | tee -a "$LOG_FILE"
  exit 1
fi

# Check PostgreSQL is accepting connections
if ! docker exec timescaledb psql -U postgres -d "$DATABASE_NAME" -c "SELECT version();" > /dev/null 2>&1; then
  log "ERROR: Cannot connect to PostgreSQL"
  docker logs timescaledb | tail -50 | tee -a "$LOG_FILE"
  exit 1
fi

# Check TimescaleDB extension is loaded
TIMESCALEDB_VERSION=$(docker exec timescaledb psql -U postgres -d "$DATABASE_NAME" -tAc "SELECT extversion FROM pg_extension WHERE extname='timescaledb'" || echo "NOT INSTALLED")
if [ "$TIMESCALEDB_VERSION" = "NOT INSTALLED" ]; then
  log "ERROR: TimescaleDB extension not installed"
  exit 1
fi

log "Health check passed!"

# ============================================================================
# Summary
# ============================================================================

log "============================================"
log "TimescaleDB Setup Complete!"
log "============================================"
log "PostgreSQL version: $(docker exec timescaledb psql -U postgres -tAc "SELECT version();" | head -1)"
log "TimescaleDB version: $TIMESCALEDB_VERSION"
log "Database name: $DATABASE_NAME"
log "Data directory: $MOUNT_POINT/pgdata"
log "Connection: postgresql://postgres:***@localhost:5432/$DATABASE_NAME"
log "Docker status: $(docker ps --filter name=timescaledb --format '{{.Status}}')"
log "Disk usage: $(df -h "$MOUNT_POINT" | tail -1)"
log "============================================"

# Write success marker
touch /var/log/timescaledb-setup-complete

log "Setup script finished successfully"
