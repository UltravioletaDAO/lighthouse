# Lighthouse Terraform Infrastructure

Infrastructure as Code for deploying Lighthouse monitoring platform on AWS.

---

## Quick Navigation

### Documentation
- **[Deployment Guide](./DEPLOYMENT-GUIDE.md)** - Step-by-step deployment instructions
- **[Architecture Analysis](../TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md)** - Full architecture (15K words)
- **[Deployment Summary](../TIMESCALEDB-DEPLOYMENT-SUMMARY.md)** - Executive summary

### Terraform Modules
- **[timescaledb-ec2](./modules/timescaledb-ec2/)** - Self-managed TimescaleDB on EC2

### Environments
- **[dev](./environments/dev/)** - Development environment ($4/month)
- **[prod](./environments/prod/)** - Production environment ($22/month)

### Tools
- **[cost-calculator.sh](./cost-calculator.sh)** - Cost estimation tool

---

## Quick Start

### Calculate Costs

```bash
cd lighthouse/terraform

# Development
./cost-calculator.sh t4g.micro 20 true

# Production Year 1-2
./cost-calculator.sh t4g.small 100 false

# Production Year 3
./cost-calculator.sh t4g.medium 500 false
```

**Output:**
```
============================================
TimescaleDB AWS Cost Estimate
============================================

Configuration:
  Instance Type:     t4g.small
  Volume Size:       100 GB (gp3)
  Spot Instance:     false
  Monitoring:        true

============================================
Cost Breakdown (Monthly)
============================================
  Instance:          $12.26/month (on-demand)
  Storage (gp3):     $8.00/month (100 GB × $0.08/GB)
  Snapshots:         $0.50/month (~10 GB × $0.05/GB)
  Monitoring:        $2.30/month (3 alarms + logs)
  ----------------------------------------
  TOTAL:             $23.06/month

============================================
Comparison: EC2 Self-Managed vs RDS
============================================
  RDS (db.t4g.small):   $37.71/month
  EC2 Self-Managed:     $23.06/month
  ----------------------------------------
  Monthly Savings:      $14.65 (39% cheaper)
  Yearly Savings:       $175.80
```

---

### Deploy Development

```bash
cd environments/dev

# Configure
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Edit ssh_key_name

# Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Get connection string
export DATABASE_URL=$(terraform output -raw database_connection_string)

# Test
psql $DATABASE_URL -c "SELECT version();"
```

**Time:** 5-8 minutes

**Cost:** $4/month

---

### Deploy Production

**Prerequisites:** See [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md#pre-deployment-checklist)

```bash
cd environments/prod

# Configure
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Update VPC, subnet, SG, etc.

# Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

**Time:** 8-12 minutes (after prerequisites)

**Cost:** $22/month (Year 1-2), $72/month (Year 3)

---

## Architecture Decision

**Recommendation:** EC2 self-managed → Migrate to RDS when revenue > $5K/month

| Metric | EC2 (3 years) | RDS (3 years) | Savings |
|--------|---------------|---------------|---------|
| **Cost** | $1,230 | $2,609 | **$1,379 (53%)** |
| **Ops Time** | 90 hours | 0 hours | -90 hours |
| **Break-Even** | $15/hour | N/A | If time worth < $20/hour, use EC2 |

See [architecture doc](../TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md) for full analysis.

---

## Cost Comparison by Year

### Year 1: MVP (50-500 subscriptions)

| Option | Cost | Use Case |
|--------|------|----------|
| EC2 t4g.micro spot | **$44/year** | Dev/staging |
| EC2 t4g.micro on-demand | **$97/year** | Production MVP |
| RDS db.t4g.micro | $174/year | Zero-ops preference |

**Recommended:** EC2 t4g.micro on-demand

---

### Year 2: Growth (500-2,000 subscriptions)

| Option | Cost | Use Case |
|--------|------|----------|
| EC2 t4g.small on-demand | **$263/year** | Production |
| RDS db.t4g.small | $453/year | Zero-ops |

**Recommended:** EC2 t4g.small

---

### Year 3: Scale (2,000-5,000 subscriptions)

| Option | Cost | Use Case |
|--------|------|----------|
| EC2 t4g.medium on-demand | **$870/year** | Cost-optimized |
| RDS db.t4g.medium single-AZ | $1,422/year | Managed |
| RDS db.t4g.medium Multi-AZ | $1,982/year | High availability |

**Recommended:**
- If revenue < $5K/month: EC2 t4g.medium
- If revenue > $5K/month: Migrate to RDS Multi-AZ

---

## Module Usage

### Basic Usage

```hcl
module "timescaledb" {
  source = "./modules/timescaledb-ec2"

  name_prefix = "lighthouse-prod"
  vpc_id      = "vpc-12345678"
  subnet_id   = "subnet-87654321"

  instance_type  = "t4g.small"
  volume_size_gb = 100

  postgres_password = data.aws_secretsmanager_secret_version.db_password.secret_string
  database_name     = "lighthouse"

  allowed_security_groups = [aws_security_group.backend.id]
}
```

### Advanced Configuration

```hcl
module "timescaledb" {
  source = "./modules/timescaledb-ec2"

  # ... basic config ...

  # Spot instance (70-90% discount)
  use_spot_instance = true  # Dev/staging only

  # Custom backup schedule
  enable_automated_backups = true
  backup_retention_days    = 30
  backup_schedule          = "cron(0 2 * * ? *)"

  # Monitoring
  enable_monitoring     = true
  cpu_alarm_threshold   = 80
  disk_alarm_threshold  = 85
  alarm_sns_topic_arn   = aws_sns_topic.alerts.arn

  # DNS
  create_dns_record = true
  route53_zone_id   = data.aws_route53_zone.main.zone_id
  dns_name          = "db.example.com"
}
```

See [module README](./modules/timescaledb-ec2/README.md) for 50+ configurable variables.

---

## Common Operations

### Scale Up Instance

```bash
# Update terraform.tfvars
instance_type = "t4g.medium"  # Was: t4g.small

# Apply
terraform plan -out=tfplan
terraform apply tfplan

# Downtime: 5-8 minutes
```

### Increase Storage

```bash
# Update terraform.tfvars
volume_size_gb = 200  # Was: 100

# Apply (zero downtime)
terraform apply

# SSH and extend filesystem
ssh ubuntu@instance
sudo growpart /dev/nvme1n1 1
sudo resize2fs /dev/nvme1n1p1
```

### Manual Backup

```bash
ssh ubuntu@instance
sudo /usr/local/bin/backup-timescaledb.sh
```

### View Costs

```bash
# AWS Cost Explorer
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-31 \
  --granularity MONTHLY \
  --metrics "BlendedCost" \
  --filter file://cost-filter.json

# Or use calculator
./cost-calculator.sh t4g.small 100 false
```

---

## File Structure

```
terraform/
├── README.md                           # This file
├── DEPLOYMENT-GUIDE.md                 # Deployment instructions
├── cost-calculator.sh                  # Cost estimation tool
│
├── modules/
│   └── timescaledb-ec2/
│       ├── main.tf                     # Module definition
│       ├── variables.tf                # Input variables
│       ├── outputs.tf                  # Outputs
│       ├── user_data.sh                # Bootstrap script
│       └── README.md                   # Module documentation
│
└── environments/
    ├── dev/
    │   ├── main.tf                     # Dev environment
    │   ├── variables.tf                # Dev variables
    │   └── terraform.tfvars.example    # Example config
    │
    └── prod/
        ├── main.tf                     # Prod environment
        ├── variables.tf                # Prod variables
        └── terraform.tfvars.example    # Example config
```

---

## Troubleshooting

### Database Won't Start

```bash
# Check logs
ssh ubuntu@instance
docker logs timescaledb

# Common fix: Permissions
sudo chown -R 999:999 /mnt/timescaledb-data/pgdata
docker restart timescaledb
```

### High CPU

```bash
# Identify slow queries
psql $DATABASE_URL << EOF
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC
LIMIT 10;
EOF

# Scale up if needed
instance_type = "t4g.medium"
terraform apply
```

### Disk Full

```bash
# Check usage
df -h /mnt/timescaledb-data

# Compress old data
psql $DATABASE_URL -c "SELECT compress_chunk(c) FROM show_chunks('check_history', older_than => INTERVAL '7 days') c;"

# Or increase volume
volume_size_gb = 200
terraform apply
```

---

## Support

- **Documentation:** [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
- **Issues:** GitHub Issues
- **Slack:** #lighthouse-infrastructure

---

**Status:** Production Ready
**Version:** 1.0
**Last Updated:** October 29, 2025
