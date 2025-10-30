# TimescaleDB EC2 Module

Deploy PostgreSQL with TimescaleDB extension on AWS EC2 with persistent EBS storage.

## Features

- **Cost-optimized:** 53% cheaper than RDS over 3 years
- **ARM Graviton2 instances:** 20% cheaper than x86 (t4g vs t3)
- **Persistent EBS volume:** Data survives instance termination
- **Automated backups:** Daily EBS snapshots via AWS Backup
- **Spot instance support:** 70-90% discount for dev/staging
- **Docker-based:** Easy upgrades and portability
- **CloudWatch monitoring:** CPU, disk, and status alarms
- **Auto-restart:** Systemd service + spot interruption handler

## Cost Comparison

| Configuration | Monthly Cost | Annual Cost | Use Case |
|--------------|--------------|-------------|----------|
| t4g.micro + 20GB | $8 | $96 | MVP (50-500 subs) |
| t4g.small + 100GB | $22 | $264 | Growth (500-2K subs) |
| t4g.medium + 500GB | $72 | $864 | Scale (2K-5K subs) |

**Compare to RDS:**
- RDS db.t4g.small: $40/month
- EC2 t4g.small: $22/month
- **Savings: $18/month (45%)**

## Quick Start

### 1. Create terraform.tfvars

```hcl
# terraform.tfvars

name_prefix = "lighthouse-prod"
vpc_id      = "vpc-12345678"
subnet_id   = "subnet-87654321"

# Database configuration
postgres_password = "CHANGE_ME_USE_SECRETS_MANAGER" # Min 16 chars
database_name     = "lighthouse"

# Instance size (start small, scale up later)
instance_type = "t4g.micro"  # $8/month
volume_size_gb = 20          # 20 GB for Year 1

# Security (restrict to backend security group)
allowed_security_groups = ["sg-backend-12345"]
allowed_cidr_blocks     = []  # Empty = deny all except backend

# SSH access (for maintenance)
enable_ssh_access = true
key_name          = "lighthouse-prod-key"
ssh_cidr_blocks   = ["YOUR_IP/32"]  # Restrict to your IP

# Backups
enable_automated_backups = true
backup_retention_days    = 30
backup_schedule          = "cron(0 2 * * ? *)"  # 2 AM UTC daily

# Monitoring
enable_monitoring     = true
cpu_alarm_threshold   = 80
disk_alarm_threshold  = 85
alarm_sns_topic_arn   = "arn:aws:sns:us-east-1:123456789012:lighthouse-alerts"

tags = {
  Project     = "Lighthouse"
  Environment = "production"
  ManagedBy   = "Terraform"
}
```

### 2. Deploy with Terraform

```bash
cd terraform/modules/timescaledb-ec2

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Review plan and apply
terraform apply tfplan

# Get database connection string
terraform output -raw database_connection_string
# postgresql://postgres:***@10.0.1.50:5432/lighthouse
```

### 3. Connect to Database

```bash
# Export connection string
export DATABASE_URL=$(terraform output -raw database_connection_string)

# Test connection
psql $DATABASE_URL -c "SELECT version();"

# Verify TimescaleDB extension
psql $DATABASE_URL -c "SELECT extversion FROM pg_extension WHERE extname='timescaledb';"
```

### 4. Run Database Migrations

```bash
# Install sqlx-cli
cargo install sqlx-cli --no-default-features --features postgres

# Run migrations
cd lighthouse/backend
sqlx migrate run

# Verify schema
psql $DATABASE_URL -c "\dt"
# Should show: subscriptions, check_history, alert_channels, etc.
```

## Usage Examples

### Development Environment (Minimal Cost)

```hcl
module "timescaledb_dev" {
  source = "./modules/timescaledb-ec2"

  name_prefix    = "lighthouse-dev"
  vpc_id         = "vpc-dev"
  subnet_id      = "subnet-dev"

  # Minimal instance (spot for 70% discount)
  instance_type     = "t4g.micro"
  use_spot_instance = true  # $2.50/month instead of $8
  volume_size_gb    = 20

  # Relaxed security for dev
  allowed_cidr_blocks = ["10.0.0.0/16"]  # Entire VPC
  enable_ssh_access   = true
  ssh_cidr_blocks     = ["0.0.0.0/0"]

  # Minimal backups
  enable_automated_backups = true
  backup_retention_days    = 7

  # Disable monitoring (save $2/month)
  enable_monitoring = false

  postgres_password = random_password.db_password.result
  database_name     = "lighthouse_dev"

  tags = {
    Environment = "development"
  }
}
```

**Cost: ~$3.50/month** (spot instance + 20GB EBS + snapshots)

---

### Production Environment (Balanced)

```hcl
module "timescaledb_prod" {
  source = "./modules/timescaledb-ec2"

  name_prefix    = "lighthouse-prod"
  vpc_id         = data.aws_vpc.main.id
  subnet_id      = data.aws_subnet.private.id

  # On-demand instance (reliable)
  instance_type     = "t4g.small"
  use_spot_instance = false
  volume_size_gb    = 100
  volume_type       = "gp3"
  volume_iops       = 3000
  volume_encrypted  = true

  # Strict security
  allowed_security_groups = [aws_security_group.backend.id]
  allowed_cidr_blocks     = []  # Deny all except backend
  enable_ssh_access       = true
  key_name                = "lighthouse-prod-key"
  ssh_cidr_blocks         = ["YOUR_OFFICE_IP/32"]

  # Production backups
  enable_automated_backups = true
  backup_retention_days    = 30
  backup_schedule          = "cron(0 2 * * ? *)"  # 2 AM UTC
  backup_s3_bucket         = "lighthouse-backups-prod"

  # Full monitoring
  enable_monitoring     = true
  cpu_alarm_threshold   = 80
  disk_alarm_threshold  = 85
  alarm_sns_topic_arn   = aws_sns_topic.alerts.arn

  # DNS record
  create_dns_record = true
  route53_zone_id   = data.aws_route53_zone.main.zone_id
  dns_name          = "db.lighthouse.karmacadabra.ultravioletadao.xyz"

  postgres_password = data.aws_secretsmanager_secret_version.db_password.secret_string
  database_name     = "lighthouse"

  tags = {
    Environment = "production"
    CostCenter  = "infrastructure"
  }
}
```

**Cost: ~$22/month** (t4g.small + 100GB + backups + monitoring)

---

### Staging Environment (Spot + Higher Capacity)

```hcl
module "timescaledb_staging" {
  source = "./modules/timescaledb-ec2"

  name_prefix    = "lighthouse-staging"
  vpc_id         = data.aws_vpc.main.id
  subnet_id      = data.aws_subnet.private.id

  # Larger instance but spot (production-like at dev cost)
  instance_type     = "t4g.small"
  use_spot_instance = true  # ~$4/month instead of $12
  volume_size_gb    = 50

  # Moderate security
  allowed_security_groups = [aws_security_group.backend_staging.id]
  enable_ssh_access       = true
  key_name                = "lighthouse-staging-key"

  # Moderate backups
  enable_automated_backups = true
  backup_retention_days    = 14

  # Enable monitoring (same as prod)
  enable_monitoring   = true
  alarm_sns_topic_arn = aws_sns_topic.alerts_staging.arn

  postgres_password = random_password.db_password_staging.result
  database_name     = "lighthouse_staging"

  tags = {
    Environment = "staging"
  }
}
```

**Cost: ~$8/month** (spot t4g.small + 50GB)

---

## Scaling Guide

### Vertical Scaling (Increase Instance Size)

**Scenario:** Database CPU > 80%, need more resources

```bash
# 1. Create snapshot (safety)
aws ec2 create-snapshot \
  --volume-id $(terraform output -raw volume_id) \
  --description "Pre-upgrade snapshot"

# 2. Update terraform.tfvars
instance_type = "t4g.medium"  # Was: t4g.small
volume_size_gb = 200          # Was: 100

# 3. Apply changes
terraform apply

# Downtime: 5-10 minutes (instance stop/start)
```

**Cost Impact:**
- t4g.small → t4g.medium: +$12/month
- 100GB → 200GB: +$8/month
- **Total increase: +$20/month**

---

### Horizontal Scaling (Add Read Replica)

**Scenario:** Read-heavy workload, need to offload dashboard queries

```bash
# Deploy second instance as read replica
# (Requires PostgreSQL streaming replication setup)

# See: docs/POSTGRESQL_REPLICATION_SETUP.md
```

---

## Backup & Recovery

### Automated Backups

AWS Backup creates daily EBS snapshots automatically:

```bash
# List snapshots
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name lighthouse-prod-timescaledb-vault

# Create manual snapshot
aws ec2 create-snapshot \
  --volume-id $(terraform output -raw volume_id) \
  --description "Manual snapshot before migration"
```

### Restore from Snapshot

```bash
# 1. Identify snapshot
aws ec2 describe-snapshots \
  --owner-ids self \
  --filters "Name=tag:Name,Values=lighthouse-prod-timescaledb-data" \
  --query 'Snapshots | sort_by(@, &StartTime) | [-1]'

# 2. Create volume from snapshot
aws ec2 create-volume \
  --snapshot-id snap-xxxxx \
  --availability-zone us-east-1a \
  --volume-type gp3

# 3. Update Terraform to use new volume
# (Or manually attach to instance)
```

### Logical Backup (pg_dump)

```bash
# SSH into instance
ssh -i ~/.ssh/lighthouse-prod-key.pem ubuntu@$(terraform output -raw instance_public_ip)

# Run manual backup script
sudo /usr/local/bin/backup-timescaledb.sh

# Backup saved to: /mnt/timescaledb-data/backups/lighthouse_YYYYMMDD_HHMMSS.sql.gz
```

---

## Monitoring

### CloudWatch Metrics

- **CPU Utilization:** Alarm at 80%
- **Disk Usage:** Alarm at 85%
- **Instance Status:** Alarm on hardware failure
- **Custom Metrics:** Memory usage, disk I/O (via CloudWatch agent)

### Check Logs

```bash
# Setup logs
ssh ubuntu@instance
sudo tail -f /var/log/timescaledb-setup.log

# PostgreSQL logs
docker logs -f timescaledb

# Spot interruption handler logs
sudo journalctl -u spot-instance-handler -f
```

### Performance Tuning

```bash
# Connect to database
psql $DATABASE_URL

-- Check slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check table sizes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check compression ratio
SELECT
  hypertable_name,
  pg_size_pretty(before_compression_total_bytes) AS before,
  pg_size_pretty(after_compression_total_bytes) AS after,
  ROUND((before_compression_total_bytes::NUMERIC / NULLIF(after_compression_total_bytes, 0)), 2) AS ratio
FROM timescaledb_information.compression_settings
JOIN timescaledb_information.hypertables USING (hypertable_name);
```

---

## Troubleshooting

### Container won't start

```bash
# Check logs
ssh ubuntu@instance
docker logs timescaledb

# Common issues:
# - Permissions: chown -R 999:999 /mnt/timescaledb-data/pgdata
# - Corrupted data: Restore from snapshot
# - Out of disk: Increase volume_size_gb in Terraform
```

### High disk usage

```bash
# Check disk usage
df -h /mnt/timescaledb-data

# Check TimescaleDB retention policies
psql $DATABASE_URL -c "SELECT * FROM timescaledb_information.jobs WHERE proc_name = 'policy_retention';"

# Manually trigger retention
psql $DATABASE_URL -c "CALL run_job(JOB_ID);"
```

### Spot instance terminated unexpectedly

```bash
# Check termination reason
aws ec2 describe-spot-instance-requests \
  --filters "Name=instance-id,Values=$(terraform output -raw instance_id)"

# EBS volume is safe (data not lost)
# Launch new instance with same Terraform config
terraform apply

# Volume will auto-attach, data intact
```

---

## Migration Paths

### From RDS to EC2

```bash
# 1. Create RDS snapshot
aws rds create-db-snapshot \
  --db-instance-identifier lighthouse-rds \
  --db-snapshot-identifier lighthouse-migration-snapshot

# 2. Export snapshot to S3
aws rds start-export-task \
  --export-task-identifier lighthouse-export \
  --source-arn arn:aws:rds:...snapshot... \
  --s3-bucket-name lighthouse-exports \
  --iam-role-arn arn:aws:iam::...role...

# 3. Import to EC2 instance
# (Use pg_restore or AWS DMS)
```

### From EC2 to RDS

```bash
# See main architecture doc:
# TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md
# Section: "Migration Path 2: EC2 → RDS"
```

---

## Variables Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name_prefix` | string | "lighthouse" | Prefix for resource names |
| `instance_type` | string | "t4g.micro" | EC2 instance type (t4g.micro\|small\|medium\|large) |
| `volume_size_gb` | number | 20 | EBS volume size in GB |
| `postgres_password` | string | (required) | PostgreSQL password (min 16 chars) |
| `use_spot_instance` | bool | false | Use spot instance (70-90% discount) |
| `enable_automated_backups` | bool | true | Enable AWS Backup daily snapshots |
| `backup_retention_days` | number | 30 | Backup retention (7-365 days) |
| `enable_monitoring` | bool | true | Enable CloudWatch alarms |

**See `variables.tf` for complete list (50+ variables).**

---

## Outputs

| Output | Description |
|--------|-------------|
| `database_endpoint` | Connection endpoint (private IP or DNS) |
| `database_connection_string` | Full PostgreSQL connection string |
| `instance_id` | EC2 instance ID |
| `volume_id` | EBS volume ID |
| `security_group_id` | Security group ID |
| `estimated_monthly_cost_usd` | Rough cost estimate |

---

## Cost Optimization Tips

1. **Start small:** t4g.micro is sufficient for 500 subscriptions
2. **Use spot for dev/staging:** 70-90% discount with < 2% interruption rate
3. **Enable compression:** TimescaleDB compresses old data (10x savings)
4. **Set retention policies:** Auto-delete data > 90 days (free up disk)
5. **Monitor disk usage:** Increase volume size before hitting 90%
6. **Use gp3 volumes:** Cheaper than gp2, same performance
7. **Avoid Multi-AZ until revenue > $5K/month:** Single instance is fine for MVP
8. **Schedule backups at low-traffic times:** Reduce I/O contention

---

## Security Best Practices

1. **Use AWS Secrets Manager for passwords:**
   ```hcl
   data "aws_secretsmanager_secret_version" "db_password" {
     secret_id = "lighthouse/db/password"
   }

   postgres_password = data.aws_secretsmanager_secret_version.db_password.secret_string
   ```

2. **Restrict PostgreSQL access to backend only:**
   ```hcl
   allowed_security_groups = [aws_security_group.backend.id]
   allowed_cidr_blocks     = []  # Deny all others
   ```

3. **Enable EBS encryption:**
   ```hcl
   volume_encrypted = true
   kms_key_id       = aws_kms_key.lighthouse.id  # Optional: custom key
   ```

4. **Use private subnet:**
   ```hcl
   subnet_id            = aws_subnet.private.id
   associate_public_ip  = false
   ```

5. **Rotate passwords quarterly:**
   ```bash
   psql $DATABASE_URL -c "ALTER USER postgres PASSWORD 'NEW_PASSWORD';"
   # Update Secrets Manager
   ```

---

## License

MIT License (same as Lighthouse project)

## Support

- **Documentation:** `lighthouse/TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md`
- **Issues:** GitHub Issues
- **Slack:** #lighthouse-infrastructure
