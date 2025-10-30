# Lighthouse TimescaleDB Deployment Guide

Complete guide for deploying TimescaleDB on AWS EC2 with Terraform.

---

## Table of Contents

1. [Quick Start (5 Minutes)](#quick-start)
2. [Pre-Deployment Checklist](#pre-deployment-checklist)
3. [Development Deployment](#development-deployment)
4. [Production Deployment](#production-deployment)
5. [Post-Deployment Verification](#post-deployment-verification)
6. [Common Operations](#common-operations)
7. [Troubleshooting](#troubleshooting)
8. [Cost Calculator](#cost-calculator)

---

## <a name="quick-start"></a>Quick Start (5 Minutes)

**Deploy development environment:**

```bash
# 1. Clone repository
git clone https://github.com/ultravioletadao/karmacadabra.git
cd karmacadabra/lighthouse/terraform/environments/dev

# 2. Create SSH key pair (if needed)
aws ec2 create-key-pair \
  --key-name lighthouse-dev \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/lighthouse-dev.pem
chmod 400 ~/.ssh/lighthouse-dev.pem

# 3. Configure Terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars if needed

# 4. Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# 5. Get database connection
export DATABASE_URL=$(terraform output -raw database_connection_string)
echo $DATABASE_URL

# 6. Test connection
psql $DATABASE_URL -c "SELECT version();"
```

**Total time:** 5-8 minutes (EC2 instance launch + Docker setup)

**Cost:** ~$4/month (spot instance)

---

## <a name="pre-deployment-checklist"></a>Pre-Deployment Checklist

### Development Environment

- [ ] AWS account with admin permissions
- [ ] AWS CLI configured (`aws configure`)
- [ ] Terraform 1.5+ installed (`terraform --version`)
- [ ] EC2 key pair created (or specify existing in tfvars)
- [ ] Default VPC exists (or specify custom VPC)

**Estimated setup time:** 10 minutes

---

### Production Environment

**Prerequisites:**

- [ ] **VPC with public and private subnets**
  ```bash
  # Create VPC (or use existing)
  aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=lighthouse-prod-vpc}]'
  ```

- [ ] **Backend security group** (for database access)
  ```bash
  aws ec2 create-security-group \
    --group-name lighthouse-prod-backend-sg \
    --description "Backend servers for Lighthouse" \
    --vpc-id vpc-xxxxx
  ```

- [ ] **SNS topic for alerts**
  ```bash
  aws sns create-topic --name lighthouse-prod-alerts
  aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:123456789012:lighthouse-prod-alerts \
    --protocol email \
    --notification-endpoint ops@example.com
  ```

- [ ] **S3 bucket for backups**
  ```bash
  aws s3 mb s3://lighthouse-backups-prod
  aws s3api put-bucket-versioning \
    --bucket lighthouse-backups-prod \
    --versioning-configuration Status=Enabled
  ```

- [ ] **Secrets Manager secret for database password**
  ```bash
  # Generate strong password
  PASSWORD=$(openssl rand -base64 32)

  # Store in Secrets Manager
  aws secretsmanager create-secret \
    --name lighthouse/prod/db/password \
    --description "TimescaleDB password for production" \
    --secret-string "$PASSWORD"
  ```

- [ ] **EC2 key pair** (emergency SSH access)
  ```bash
  aws ec2 create-key-pair \
    --key-name lighthouse-prod \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/lighthouse-prod.pem
  chmod 400 ~/.ssh/lighthouse-prod.pem
  ```

- [ ] **S3 backend for Terraform state**
  ```bash
  aws s3 mb s3://lighthouse-terraform-state
  aws s3api put-bucket-versioning \
    --bucket lighthouse-terraform-state \
    --versioning-configuration Status=Enabled
  aws s3api put-bucket-encryption \
    --bucket lighthouse-terraform-state \
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

  # DynamoDB for state locking
  aws dynamodb create-table \
    --table-name lighthouse-terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
  ```

**Estimated setup time:** 30-45 minutes

---

## <a name="development-deployment"></a>Development Deployment

**Configuration:** t4g.micro spot instance + 20GB storage

**Cost:** ~$4/month

### Step 1: Configure

```bash
cd lighthouse/terraform/environments/dev

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars
vim terraform.tfvars
```

**terraform.tfvars:**
```hcl
aws_region   = "us-east-1"
ssh_key_name = "lighthouse-dev"  # Your SSH key name
```

### Step 2: Deploy

```bash
# Initialize Terraform
terraform init

# Plan deployment (review changes)
terraform plan -out=tfplan

# Apply (deploy resources)
terraform apply tfplan
```

**Output:**
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

database_endpoint = "10.0.1.50"
estimated_monthly_cost = "$3.85"
ssh_command = "ssh -i ~/.ssh/lighthouse-dev.pem ubuntu@54.123.45.67"
```

### Step 3: Verify

```bash
# Get database password
DB_PASSWORD=$(aws ssm get-parameter \
  --name /lighthouse/dev/db/password \
  --with-decryption \
  --query 'Parameter.Value' \
  --output text)

# Build connection string
DB_ENDPOINT=$(terraform output -raw database_endpoint)
export DATABASE_URL="postgresql://postgres:$DB_PASSWORD@$DB_ENDPOINT:5432/lighthouse_dev"

# Test connection
psql $DATABASE_URL -c "SELECT version();"
```

**Expected output:**
```
                                                 version
----------------------------------------------------------------------------------------------------------
 PostgreSQL 16.1 on aarch64-unknown-linux-gnu, compiled by gcc (GCC) 12.2.0, 64-bit
(1 row)
```

### Step 4: Run Migrations

```bash
cd lighthouse/backend

# Install sqlx-cli
cargo install sqlx-cli --no-default-features --features postgres

# Run migrations
sqlx migrate run

# Verify schema
psql $DATABASE_URL -c "\dt"
```

**Expected tables:**
- users
- subscriptions
- alert_channels
- check_history (hypertable)
- alert_history (hypertable)
- hourly_metrics (continuous aggregate)
- daily_metrics (continuous aggregate)

---

## <a name="production-deployment"></a>Production Deployment

**Configuration:** t4g.small on-demand + 100GB storage + backups + monitoring

**Cost:** ~$22/month

### Step 1: Create Infrastructure

Follow [Pre-Deployment Checklist](#pre-deployment-checklist) to create:
- VPC with subnets
- Security groups
- SNS topic
- S3 buckets
- Secrets Manager secret

### Step 2: Configure Terraform

```bash
cd lighthouse/terraform/environments/prod

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
vim terraform.tfvars
```

**terraform.tfvars:**
```hcl
aws_region = "us-east-1"

# Network (update with your VPC details)
vpc_name                     = "lighthouse-prod-vpc"
private_subnet_name          = "lighthouse-prod-private-subnet"
backend_security_group_name  = "lighthouse-prod-backend-sg"

# Database
instance_type  = "t4g.small"
volume_size_gb = 100

# Secrets
db_password_secret_id = "lighthouse/prod/db/password"

# Backups
backup_s3_bucket = "lighthouse-backups-prod"

# Monitoring
alerts_sns_topic_name = "lighthouse-prod-alerts"

# DNS
domain_name = "karmacadabra.ultravioletadao.xyz"

# SSH (restrict to VPN/bastion)
ssh_key_name            = "lighthouse-prod"
ssh_allowed_cidr_blocks = ["10.0.0.0/16"]  # Internal only
```

### Step 3: Deploy

```bash
# Initialize Terraform (downloads modules, configures S3 backend)
terraform init

# Format and validate
terraform fmt
terraform validate

# Plan (review all changes)
terraform plan -out=tfplan

# Review plan carefully - this is production!
less tfplan

# Apply
terraform apply tfplan
```

**Deployment time:** 8-12 minutes

### Step 4: Post-Deployment

```bash
# Get instance details
terraform output instance_id
terraform output database_endpoint
terraform output cloudwatch_dashboard_url

# Verify instance is running
aws ec2 describe-instances \
  --instance-ids $(terraform output -raw instance_id) \
  --query 'Reservations[0].Instances[0].State.Name'

# Should output: "running"
```

---

## <a name="post-deployment-verification"></a>Post-Deployment Verification

### 1. Database Connectivity Test

**From backend server (within VPC):**

```bash
# Get connection details
export DATABASE_URL=$(terraform output -raw database_connection_string)

# Test connection
psql $DATABASE_URL -c "SELECT current_database(), version();"

# Verify TimescaleDB extension
psql $DATABASE_URL -c "SELECT extversion FROM pg_extension WHERE extname='timescaledb';"
```

### 2. Run Migrations

```bash
cd lighthouse/backend

# Set DATABASE_URL
export DATABASE_URL="postgresql://postgres:PASSWORD@db.example.com:5432/lighthouse"

# Run migrations
sqlx migrate run

# Verify schema
psql $DATABASE_URL << EOF
\dt                          -- List tables
\dv                          -- List views (continuous aggregates)
SELECT * FROM timescaledb_information.hypertables;
SELECT * FROM timescaledb_information.continuous_aggregates;
EOF
```

### 3. Performance Benchmark

```bash
# Insert test data
psql $DATABASE_URL << EOF
-- Insert 10,000 test check results
INSERT INTO check_history (time, subscription_id, status, http_status, latency_ms)
SELECT
  NOW() - (i || ' minutes')::INTERVAL,
  gen_random_uuid(),
  CASE WHEN random() < 0.95 THEN 'success' ELSE 'failure' END,
  CASE WHEN random() < 0.95 THEN 200 ELSE 500 END,
  (random() * 500)::INT
FROM generate_series(1, 10000) AS i;
EOF

# Benchmark query performance
psql $DATABASE_URL << EOF
\timing on

-- Query 1: Recent checks (should be < 10ms)
SELECT * FROM check_history ORDER BY time DESC LIMIT 100;

-- Query 2: Hourly metrics (should be < 20ms)
SELECT * FROM hourly_metrics WHERE hour > NOW() - INTERVAL '24 hours';

-- Query 3: Uptime calculation (should be < 50ms)
SELECT
  subscription_id,
  AVG(uptime_ratio) * 100 AS uptime_percent
FROM daily_metrics
WHERE day > NOW() - INTERVAL '30 days'
GROUP BY subscription_id;
EOF
```

**Expected performance:**
- Recent checks: < 10ms
- Hourly metrics: < 20ms
- Uptime calculation: < 50ms

### 4. Backup Verification

```bash
# List backups
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name lighthouse-prod-timescaledb-vault

# Verify latest backup
aws backup describe-recovery-point \
  --backup-vault-name lighthouse-prod-timescaledb-vault \
  --recovery-point-arn <latest-arn>

# Expected: Status = "COMPLETED", Size > 0
```

### 5. Monitoring Verification

```bash
# Check CloudWatch alarms
aws cloudwatch describe-alarms \
  --alarm-name-prefix lighthouse-prod-timescaledb

# Verify SNS subscription
aws sns list-subscriptions-by-topic \
  --topic-arn $(terraform output -raw alarm_sns_topic_arn)

# Test alarm (trigger CPU spike)
ssh ubuntu@instance "stress-ng --cpu 2 --timeout 180s"
# Check email/Slack for alarm notification
```

### 6. SSH Access Test

```bash
# Via bastion (production)
ssh -J bastion-host ubuntu@$(terraform output -raw instance_private_ip)

# Or via Systems Manager (no SSH key needed)
aws ssm start-session --target $(terraform output -raw instance_id)

# Once connected, verify Docker
docker ps
docker logs timescaledb | tail -50
```

---

## <a name="common-operations"></a>Common Operations

### Scale Up Instance

**Scenario:** Database CPU consistently > 80%

```bash
# 1. Update terraform.tfvars
instance_type = "t4g.medium"  # Was: t4g.small

# 2. Plan and apply
terraform plan -out=tfplan
terraform apply tfplan

# Downtime: 5-8 minutes (instance stop/start)
```

### Increase Storage

**Scenario:** Disk usage > 80%

```bash
# 1. Update terraform.tfvars
volume_size_gb = 200  # Was: 100

# 2. Apply changes
terraform plan -out=tfplan
terraform apply tfplan

# 3. SSH and extend filesystem
ssh ubuntu@instance
sudo growpart /dev/nvme1n1 1
sudo resize2fs /dev/nvme1n1p1
df -h /mnt/timescaledb-data  # Verify new size
```

**Downtime:** None (online resize)

### Manual Backup

```bash
# SSH to instance
ssh ubuntu@instance

# Run backup script
sudo /usr/local/bin/backup-timescaledb.sh

# Verify backup
ls -lh /mnt/timescaledb-data/backups/
```

### Restore from Backup

```bash
# 1. Stop database
docker stop timescaledb

# 2. Identify backup file
ls -lh /mnt/timescaledb-data/backups/

# 3. Restore
gunzip < /mnt/timescaledb-data/backups/lighthouse_20251029_120000.sql.gz | \
  docker exec -i timescaledb psql -U postgres -d lighthouse

# 4. Start database
docker start timescaledb
```

### Update TimescaleDB Version

```bash
# 1. SSH to instance
ssh ubuntu@instance

# 2. Pull new image
docker pull timescale/timescaledb:latest-pg16

# 3. Update docker-compose.yml (if needed)
sudo vim /opt/docker-compose.yml

# 4. Recreate container
cd /opt
docker compose down
docker compose up -d

# 5. Verify version
docker exec timescaledb psql -U postgres -d lighthouse -c "SELECT extversion FROM pg_extension WHERE extname='timescaledb';"
```

---

## <a name="troubleshooting"></a>Troubleshooting

### Database Won't Start

**Symptoms:** `docker ps` shows TimescaleDB not running

```bash
# Check logs
docker logs timescaledb

# Common issues:

# 1. Permission issue
sudo chown -R 999:999 /mnt/timescaledb-data/pgdata
docker restart timescaledb

# 2. Corrupted data directory
# Restore from snapshot (see architecture doc)

# 3. Out of disk space
df -h /mnt/timescaledb-data
# Increase volume_size_gb if needed
```

### High CPU Usage

**Symptoms:** CloudWatch alarm, slow queries

```bash
# Identify slow queries
psql $DATABASE_URL << EOF
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC
LIMIT 10;
EOF

# Solutions:
# 1. Add missing indexes
# 2. Scale up instance (t4g.small → t4g.medium)
# 3. Enable query result caching
```

### Disk Full

**Symptoms:** Database writes failing, errors in logs

```bash
# Check disk usage
df -h /mnt/timescaledb-data

# Free up space:
# 1. Manually compress old chunks
psql $DATABASE_URL -c "SELECT compress_chunk(c) FROM show_chunks('check_history', older_than => INTERVAL '7 days') c;"

# 2. Reduce retention period
psql $DATABASE_URL -c "SELECT alter_job((SELECT job_id FROM timescaledb_information.jobs WHERE proc_name='policy_retention'), config => '{\"drop_after\": \"30 days\"}');"

# 3. Increase volume size (see "Increase Storage" above)
```

### Spot Instance Terminated

**Symptoms:** Instance stopped unexpectedly

```bash
# Check if spot interruption
aws ec2 describe-spot-instance-requests \
  --filters "Name=instance-id,Values=$(terraform output -raw instance_id)"

# Data is safe on EBS volume
# Start new instance:
terraform apply -auto-approve

# Volume will auto-attach, database will resume
```

---

## <a name="cost-calculator"></a>Cost Calculator

### Formula

```
Monthly Cost = (Instance + Storage + Snapshots + Monitoring)

Instance Cost:
  - t4g.micro on-demand:  $0.0084/hour × 730 hours = $6.13/month
  - t4g.small on-demand:  $0.0168/hour × 730 hours = $12.26/month
  - t4g.medium on-demand: $0.0336/hour × 730 hours = $24.53/month
  - Spot discount: 70-90% (multiply by 0.10-0.30)

Storage Cost (gp3):
  - EBS volume: $0.08/GB/month
  - Snapshots: ~10% of volume × $0.05/GB/month

Monitoring Cost:
  - CloudWatch alarms: $0.10/alarm × 3 alarms = $0.30/month
  - CloudWatch logs: ~$2/month
  - CloudWatch agent: Free
```

### Examples

**Development (t4g.micro spot + 20GB):**
```
Instance:  $6.13 × 0.30 (spot) = $1.84
Storage:   20 GB × $0.08 = $1.60
Snapshots: 2 GB × $0.05 = $0.10
Monitoring: $0 (disabled)
---
TOTAL: $3.54/month
```

**Production Year 1 (t4g.small + 100GB):**
```
Instance:  $12.26
Storage:   100 GB × $0.08 = $8.00
Snapshots: 10 GB × $0.05 = $0.50
Monitoring: $2.30
---
TOTAL: $23.06/month = $276.72/year
```

**Production Year 3 (t4g.medium + 500GB):**
```
Instance:  $24.53
Storage:   500 GB × $0.08 = $40.00
Snapshots: 50 GB × $0.05 = $2.50
Monitoring: $2.30
---
TOTAL: $69.33/month = $831.96/year
```

### Cost Optimization Tips

1. **Use spot for dev/staging:** Save 70-90%
2. **Start small, scale later:** t4g.micro handles 500 subscriptions
3. **Enable compression:** 10x storage savings after 7 days
4. **Set retention policies:** Delete data > 90 days
5. **Monitor actual usage:** Scale up only when CPU > 80% sustained
6. **Use gp3 over gp2:** Same price, better performance
7. **Cross-region backups only if needed:** Doubles snapshot cost

---

## Next Steps

1. **Deploy development environment** (5 minutes, $4/month)
2. **Test with sample data** (insert 10K checks, verify queries)
3. **Run backend integration tests** (ensure API works with TimescaleDB)
4. **Deploy production** when ready ($22/month, 500-2K subscriptions)
5. **Monitor costs** in AWS Cost Explorer after 1 week
6. **Plan scaling** when approaching limits:
   - CPU > 70%: Scale instance type
   - Disk > 80%: Increase volume size
   - 2,000+ subscriptions: Consider RDS Multi-AZ

---

**Document Status:** Production Ready
**Last Updated:** October 29, 2025
**Related Files:**
- `TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md` - Architecture decisions
- `modules/timescaledb-ec2/README.md` - Module documentation
- `environments/*/main.tf` - Environment configurations
