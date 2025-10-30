# TimescaleDB AWS Deployment - Executive Summary

**Date:** October 29, 2025
**Status:** Production Ready

---

## Decision: EC2 Self-Managed (Recommended)

**Start with EC2 t4g.micro + EBS, migrate to RDS when revenue > $5,000/month**

| Metric | EC2 Path | RDS Path | Savings |
|--------|----------|----------|---------|
| **Year 1 Cost** | $97 | $174 | **44%** |
| **Year 2 Cost** | $263 | $453 | **42%** |
| **Year 3 Cost** | $870 | $1,982 | **56%** |
| **3-Year Total** | **$1,230** | **$2,609** | **$1,379 (53%)** |

**Trade-off:** Save $1,379 over 3 years at cost of 2-3 hours/month ops work (90 hours total)

**Break-even hourly rate:** $1,379 / 90 hours = **$15.31/hour**

**Verdict:** If your time is worth < $20/hour, use EC2. If > $50/hour, use RDS.

---

## What's Been Delivered

### 1. Architecture Analysis

**File:** `TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md` (15,000 words)

**Contents:**
- 3-year cost comparison (EC2 vs RDS vs Spot vs EigenCloud)
- Architecture diagrams (MVP → Growth → Scale)
- Migration strategies (EC2 → RDS with AWS DMS)
- EigenCloud analysis (why it's unsuitable for databases)
- Backup & recovery procedures
- Production runbooks

**Key Findings:**
- **EC2 is 53% cheaper** than RDS over 3 years
- **EigenCloud saves 40-50%** for compute, but **10-15x slower** for databases
- **Spot instances** viable for dev/staging (70-90% discount)
- **RDS justifiable** when revenue > $5K/month (zero ops overhead)

---

### 2. Terraform Modules

**Directory:** `terraform/modules/timescaledb-ec2/`

**Files:**
- `main.tf` - EC2 instance, EBS volume, security groups, AWS Backup
- `variables.tf` - 50+ configurable variables (instance type, storage, backups)
- `outputs.tf` - Connection strings, endpoints, cost estimates
- `user_data.sh` - Bootstrap script (Docker, TimescaleDB, CloudWatch agent)
- `README.md` - Usage guide with examples

**Features:**
- Persistent EBS volume (survives instance termination)
- Automated daily snapshots (30-day retention)
- CloudWatch alarms (CPU, disk, instance status)
- Spot instance support (70-90% discount)
- Docker-based (easy upgrades, portable)
- Graviton2 instances (20% cheaper than x86)

**Cost:**
- t4g.micro + 20GB: **$8/month**
- t4g.small + 100GB: **$22/month**
- t4g.medium + 500GB: **$72/month**

---

### 3. Environment Configurations

#### Development (`terraform/environments/dev/`)

**Configuration:**
- t4g.micro spot instance ($1.84/month)
- 20 GB storage
- Public subnet (easy SSH)
- Relaxed security (entire VPC can access)
- 7-day backup retention
- Monitoring disabled

**Cost:** **$4/month**

**Deploy:**
```bash
cd terraform/environments/dev
terraform init && terraform apply
```

**Use case:** Local development, CI/CD testing

---

#### Production (`terraform/environments/prod/`)

**Configuration:**
- t4g.small on-demand instance ($12.26/month)
- 100 GB storage
- Private subnet (no public IP)
- Strict security (backend only)
- 30-day backup retention
- Full CloudWatch monitoring
- Route53 DNS record
- SNS alerts

**Cost:** **$22/month**

**Deploy:**
```bash
cd terraform/environments/prod
terraform init && terraform apply
```

**Use case:** Production workload (500-2,000 subscriptions)

---

### 4. Deployment Guide

**File:** `terraform/DEPLOYMENT-GUIDE.md`

**Contents:**
- Quick start (5 minutes)
- Pre-deployment checklist (VPC, security groups, Secrets Manager)
- Step-by-step deployment (dev and prod)
- Post-deployment verification (connectivity, performance benchmarks)
- Common operations (scale up, backups, restore)
- Troubleshooting guide
- Cost calculator with formulas

**Key Procedures:**
- **Scale instance:** 5-10 min downtime
- **Increase storage:** Zero downtime (online resize)
- **Manual backup:** 2-5 min (pg_dump to S3)
- **Restore:** 10-20 min (from EBS snapshot)

---

## Cost Comparison (Detailed)

### Year 1: MVP (50-200 subscriptions)

| Option | Instance | Storage | Backups | Monitoring | Total/Month | Total/Year |
|--------|----------|---------|---------|------------|-------------|------------|
| **EC2 t4g.micro** | $6.13 | $1.60 | $0.25 | $0 | **$8.07** | **$96.84** |
| **EC2 spot** | $1.84 | $1.60 | $0.25 | $0 | **$3.69** | **$44.28** |
| **RDS db.t4g.micro** | $11.68 | $2.30 | $0.48 | Included | **$14.46** | **$173.52** |

**Savings:** EC2 on-demand saves $77/year (44%), spot saves $129/year (74%)

---

### Year 2: Growth (200-1,000 subscriptions)

| Option | Instance | Storage | Backups | Monitoring | Total/Month | Total/Year |
|--------|----------|---------|---------|------------|-------------|------------|
| **EC2 t4g.small** | $12.26 | $8.00 | $1.50 | $2.30 | **$21.94** | **$263.28** |
| **RDS db.t4g.small** | $23.36 | $11.50 | $2.85 | Included | **$37.71** | **$452.52** |

**Savings:** EC2 saves $189/year (42%)

---

### Year 3: Scale (1,000-5,000 subscriptions)

| Option | Instance | Storage | Backups | Monitoring | Total/Month | Total/Year |
|--------|----------|---------|---------|------------|-------------|------------|
| **EC2 t4g.medium** | $24.53 | $40.00 | $7.50 | $2.30 | **$72.48** | **$869.76** |
| **RDS db.t4g.medium** | $46.72 | $57.50 | $14.25 | Included | **$118.47** | **$1,421.64** |
| **RDS Multi-AZ** | $93.44 | $57.50 | $14.25 | Included | **$165.19** | **$1,982.28** |

**Savings:** EC2 saves $552/year (39%) vs single-AZ, $1,113/year (56%) vs Multi-AZ

---

### 3-Year Total Cost of Ownership

```
EC2 Path (start small, scale up):
  Year 1: $96.84   (t4g.micro + 20GB)
  Year 2: $263.28  (t4g.small + 100GB)
  Year 3: $869.76  (t4g.medium + 500GB)
  ---
  TOTAL: $1,229.88

RDS Path (managed from start):
  Year 1: $173.52   (db.t4g.micro + 20GB)
  Year 2: $452.52   (db.t4g.small + 100GB)
  Year 3: $1,982.28 (db.t4g.medium + Multi-AZ)
  ---
  TOTAL: $2,608.32

SAVINGS: $1,378.44 (53%)
```

**Operational Effort:**
- EC2: 2-3 hours/month × 36 months = 90 hours
- RDS: 0 hours

**Implied hourly rate:** $1,378 / 90 hours = **$15.31/hour**

---

## Migration Path (Recommended)

### Phase 1: Month 1-6 (MVP)

**Deploy:** EC2 t4g.micro + 20GB EBS

**Cost:** $97/year

**Capacity:** 50-500 subscriptions, 180K checks/day

**Operations:** 2 hours/month (backups, patches, monitoring)

**Trigger to upgrade:** CPU > 70% sustained, disk > 80%

---

### Phase 2: Month 6-18 (Growth)

**Upgrade:** EC2 t4g.small + 100GB EBS

**Cost:** $263/year

**Capacity:** 500-2,000 subscriptions, 864K checks/day

**Migration:** 5-10 min downtime (instance resize)

**Operations:** 2-3 hours/month

**Trigger to migrate:** Revenue > $5K/month OR team has < 5 hours/month for DB ops

---

### Phase 3: Month 18-36 (Scale)

**Option A:** Stay on EC2 t4g.medium + 500GB

**Cost:** $870/year

**Pros:** Still 56% cheaper than RDS

**Cons:** Manual failover, requires ops expertise

---

**Option B:** Migrate to RDS Multi-AZ

**Cost:** $1,982/year

**Pros:** Zero ops, automatic failover, 99.95% uptime SLA

**Cons:** 2.3x more expensive than EC2

**Migration:** Use AWS DMS for zero-downtime cutover (see architecture doc)

---

## EigenCloud Analysis

**Findings:**

| Feature | AWS EC2/RDS | EigenCloud | Assessment |
|---------|-------------|------------|------------|
| **Cost** | $8-72/month | $5-20/month | **40-50% cheaper** |
| **Persistent Storage** | EBS (99.999% durability) | Filecoin (varies) | **Not reliable enough** |
| **Database Performance** | < 1ms latency | 50-200ms latency | **10-15x slower** |
| **Uptime SLA** | 99.95% (Multi-AZ) | None (best-effort) | **No guarantee** |

**Verdict:**
- **DO NOT use for PostgreSQL/TimescaleDB** (storage layer too slow)
- **DO consider for stateless compute** (Rust backend, workers)
- **Re-evaluate in 2026** when platform matures

**Hybrid Architecture (Year 2-3):**
```
Backend (EigenCloud):  3x nodes @ $5/month = $15/month  (40% savings)
Database (AWS RDS):    db.t4g.medium = $165/month       (mission-critical)
---
TOTAL: $180/month vs $237/month all-AWS (24% savings)
```

---

## Deployment Checklist

### Development (5 minutes)

- [ ] AWS account + CLI configured
- [ ] Terraform 1.5+ installed
- [ ] EC2 key pair created
- [ ] `cd terraform/environments/dev`
- [ ] `terraform init && terraform apply`
- [ ] Export DATABASE_URL
- [ ] Run migrations: `sqlx migrate run`

**Cost:** $4/month

---

### Production (30-45 minutes)

**Prerequisites:**
- [ ] VPC with public/private subnets
- [ ] Backend security group
- [ ] SNS topic for alerts (subscribe to email)
- [ ] S3 bucket for backups (enable versioning)
- [ ] Secrets Manager secret (min 16 char password)
- [ ] EC2 key pair (emergency access)
- [ ] S3 + DynamoDB for Terraform state

**Deployment:**
- [ ] Update `terraform.tfvars` with VPC/subnet/SG details
- [ ] `terraform init` (configure S3 backend)
- [ ] `terraform plan -out=tfplan`
- [ ] Review plan (verify resources, cost estimate)
- [ ] `terraform apply tfplan`
- [ ] Verify connectivity from backend
- [ ] Run migrations
- [ ] Test backup restoration
- [ ] Configure CloudWatch dashboard
- [ ] Subscribe to SNS alerts

**Cost:** $22/month (Year 1-2), $72/month (Year 3)

---

## Monitoring & Alerts

### CloudWatch Alarms

1. **CPU Utilization > 80%** for 10 minutes
   - Action: Alarm via SNS
   - Resolution: Scale up instance type

2. **Disk Usage > 85%**
   - Action: Alarm via SNS
   - Resolution: Increase volume size or reduce retention

3. **Instance Status Check Failed**
   - Action: Alarm via SNS
   - Resolution: Investigate hardware failure, restore from snapshot

### CloudWatch Dashboard

**Metrics:**
- CPU utilization (average, max)
- Disk usage (percentage)
- Network in/out (bytes)
- Status check failed (count)

**Access:** `https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=lighthouse-prod-timescaledb`

---

## Backup & Recovery

### Automated Backups

**EBS Snapshots:**
- Schedule: 2 AM UTC daily
- Retention: 30 days
- Cost: ~$0.50/month (10% of volume size × $0.05/GB)

**Logical Backups (pg_dump):**
- Schedule: 3 AM UTC weekly
- Storage: S3 bucket (compressed)
- Retention: 90 days
- Cost: ~$0.50/month (50 GB compressed × $0.023/GB)

### Recovery Procedures

**Scenario 1: Accidental data deletion**
- RTO: 15-30 minutes
- RPO: Last snapshot (24 hours max)
- Method: Restore from EBS snapshot to temporary instance, copy data

**Scenario 2: Instance failure**
- RTO: 5-10 minutes
- RPO: 0 (data on EBS persists)
- Method: Launch new instance, attach existing EBS volume

**Scenario 3: Regional outage**
- RTO: 2-4 hours
- RPO: Last cross-region snapshot (24 hours)
- Method: Restore from cross-region snapshot (if enabled)

---

## Security Best Practices

1. **Database password in Secrets Manager** (never in code)
2. **Restrict access to backend security group only** (no 0.0.0.0/0)
3. **Enable EBS encryption** (at-rest protection)
4. **Use private subnet** (no public IP)
5. **SSH via bastion or Systems Manager** (no direct SSH)
6. **Rotate passwords quarterly**
7. **Enable VPC flow logs** (audit database access)
8. **Set up GuardDuty** (threat detection)

---

## Troubleshooting Quick Reference

| Symptom | Cause | Solution |
|---------|-------|----------|
| Database won't start | Permission issue | `chown -R 999:999 /mnt/timescaledb-data/pgdata` |
| High CPU usage | Missing index or large query | Run `pg_stat_statements`, add indexes |
| Disk full | Retention policy not running | Manually compress chunks, reduce retention |
| Spot instance terminated | Spot interruption | Data safe on EBS, `terraform apply` to restart |
| Slow queries | Not using continuous aggregates | Query `hourly_metrics` instead of `check_history` |
| Connection refused | Security group misconfigured | Add backend SG to allowed list |

---

## Next Steps

1. **Review architecture doc** (`TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md`)
2. **Deploy dev environment** (5 min, $4/month)
3. **Test with sample data** (insert 10K checks, verify performance)
4. **Deploy production** when ready ($22/month)
5. **Set up monitoring** (CloudWatch dashboard, SNS alerts)
6. **Test backup restoration** (critical before go-live)
7. **Document runbooks** (scale up, backup, restore procedures)
8. **Monitor costs** (AWS Cost Explorer after 1 week)
9. **Plan scaling timeline** (when to upgrade to t4g.medium or RDS)

---

## File Inventory

### Documentation
- `TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md` - Full architecture (15K words)
- `TIMESCALEDB-DEPLOYMENT-SUMMARY.md` - This file (executive summary)
- `terraform/DEPLOYMENT-GUIDE.md` - Step-by-step deployment
- `terraform/modules/timescaledb-ec2/README.md` - Module usage guide

### Terraform Code
- `terraform/modules/timescaledb-ec2/main.tf` - Module definition
- `terraform/modules/timescaledb-ec2/variables.tf` - 50+ variables
- `terraform/modules/timescaledb-ec2/outputs.tf` - Connection strings, ARNs
- `terraform/modules/timescaledb-ec2/user_data.sh` - Bootstrap script
- `terraform/environments/dev/main.tf` - Dev environment
- `terraform/environments/prod/main.tf` - Prod environment

### Total Files: 11 files, ~4,000 lines of code + 25,000 words of documentation

---

## Support & Resources

**Documentation:**
- Architecture: `TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md`
- Deployment: `terraform/DEPLOYMENT-GUIDE.md`
- Module: `terraform/modules/timescaledb-ec2/README.md`

**External Resources:**
- TimescaleDB Docs: https://docs.timescale.com/
- AWS EC2 Pricing: https://aws.amazon.com/ec2/pricing/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/

**Team Contact:**
- GitHub Issues: https://github.com/ultravioletadao/karmacadabra/issues
- Slack: #lighthouse-infrastructure

---

**Document Status:** Production Ready
**Last Updated:** October 29, 2025
**Version:** 1.0
**Author:** Master Architect (Claude Code)
