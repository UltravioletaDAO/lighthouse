# 🚀 Lighthouse Deployment: Granular Step-by-Step Guide

**Status:** Planning Phase | **Date:** October 29, 2025

---

## 📋 Table of Contents

1. [Deployment Options Comparison](#deployment-options-comparison)
2. [Prerequisites](#prerequisites)
3. [Option A: Local Development (Docker Compose)](#option-a-local-development-docker-compose)
4. [Option B: AWS Production (Terraform)](#option-b-aws-production-terraform)
5. [Option C: EigenCloud Hybrid (Research)](#option-c-eigencloud-hybrid-research)
6. [Phase-by-Phase Roadmap](#phase-by-phase-roadmap)
7. [Troubleshooting](#troubleshooting)

---

## 🔍 Deployment Options Comparison

### Summary Table

| Option | Database | Backend | Cost | Complexity | Maturity | Best For |
|--------|----------|---------|------|------------|----------|----------|
| **A. Local Dev** | Docker TimescaleDB | Docker Rust | $0 | Low | ✅ Ready | Development & testing |
| **B. AWS Prod** | EC2 + EBS | EC2 Fargate/EC2 | $8-72/mo | Medium | ✅ Ready | Production MVP |
| **C. EigenCloud Hybrid** | AWS EC2 | EigenCloud TEE | $5-50/mo | High | ⚠️ Alpha | Research only (Q3 2025) |

### Detailed Comparison

#### Option A: Local Development (Docker Compose)
```
┌─────────────────────────────────────┐
│   Your Laptop / Workstation         │
│                                     │
│  ┌──────────┐  ┌──────────┐        │
│  │  Rust    │  │TimescaleDB│        │
│  │ Backend  │  │ (Docker)  │        │
│  └──────────┘  └──────────┘        │
│       │              │              │
│       └──────┬───────┘              │
│              │                      │
│         ┌────▼────┐                 │
│         │  Redis  │                 │
│         └─────────┘                 │
└─────────────────────────────────────┘
```

**Pros:**
- ✅ Free ($0 cost)
- ✅ Fast iteration (hot reload)
- ✅ No cloud account needed
- ✅ Works offline

**Cons:**
- ❌ Not accessible from internet
- ❌ Data lost on docker-compose down (unless volumes)
- ❌ No backups
- ❌ Single machine (no scaling)

**When to use:** Development, testing, prototyping

---

#### Option B: AWS Production (Terraform)
```
┌─────────────────────────────────────────────────────────┐
│                    AWS Cloud                            │
│                                                         │
│  ┌────────────────┐         ┌────────────────┐         │
│  │  EC2 Instance  │         │  EC2 Instance  │         │
│  │   (Backend)    │────────▶│ (TimescaleDB)  │         │
│  │  t4g.small     │         │  t4g.small     │         │
│  └────────────────┘         └────────────────┘         │
│         │                            │                  │
│         │                     ┌──────▼──────┐          │
│         │                     │  EBS Volume │          │
│         │                     │ (Persistent)│          │
│         │                     └─────────────┘          │
│         │                                               │
│  ┌──────▼───────┐      ┌─────────────────┐            │
│  │ Load Balancer│      │  AWS Backup     │            │
│  │ (optional)   │      │ (Daily snapshots)│           │
│  └──────────────┘      └─────────────────┘            │
└─────────────────────────────────────────────────────────┘
```

**Pros:**
- ✅ Production-ready
- ✅ Automated backups (AWS Backup)
- ✅ Scalable (t4g.micro → t4g.xlarge)
- ✅ 99.95% uptime SLA
- ✅ Terraform IaC (repeatable deployments)
- ✅ CloudWatch monitoring

**Cons:**
- ❌ Costs $8-72/month (depending on instance size)
- ❌ Manual ops (SSH, updates, patching)
- ❌ Vendor lock-in (AWS-specific features)

**When to use:** MVP launch, production deployments

**Cost breakdown:**
```
Phase 1 (MVP):       EC2 t4g.micro  = $8/month   (50-500 subs)
Phase 2 (Growth):    EC2 t4g.small  = $22/month  (500-2K subs)
Phase 3 (Scale):     EC2 t4g.medium = $72/month  (2K-5K subs)
Alternative (Scale): RDS Multi-AZ   = $165/month (zero ops, automatic failover)
```

---

#### Option C: EigenCloud Hybrid (Research Phase)
```
┌─────────────────────────────────────────────────────────┐
│              EigenCloud (Verifiable Compute)            │
│                                                         │
│  ┌────────────────────────────────────────┐            │
│  │  EigenCompute TEE (Rust Backend)       │            │
│  │  - Docker image deployed via CLI       │            │
│  │  - Verifiable execution proofs         │            │
│  │  - 40-50% cheaper than AWS EC2         │            │
│  └────────────────┬───────────────────────┘            │
│                   │                                     │
│                   │ Cross-cloud network                 │
│                   │ (50-200ms latency)                  │
│                   │                                     │
└───────────────────┼─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│                    AWS Cloud                            │
│                                                         │
│  ┌────────────────────────────────────┐                │
│  │  EC2 Instance (TimescaleDB)        │                │
│  │  - Cannot deploy on EigenCloud     │                │
│  │  - Storage too slow (50-200ms)     │                │
│  │  - Keep on AWS for <1ms latency    │                │
│  └────────────────────────────────────┘                │
│                   │                                     │
│            ┌──────▼──────┐                              │
│            │  EBS Volume │                              │
│            │ (Persistent)│                              │
│            └─────────────┘                              │
└─────────────────────────────────────────────────────────┘
```

**Pros:**
- ✅ 40-50% cheaper compute ($5-20/month vs $8-72/month AWS)
- ✅ Verifiable execution (on-chain proofs)
- ✅ Decentralized infrastructure
- ✅ Crypto-native payments (restaking economics)

**Cons:**
- ❌ **Currently in ALPHA** (EigenCompute mainnet alpha, Q3 2025)
- ❌ **Cannot run databases** (EigenDA = short-term storage only, 50-200ms latency)
- ❌ **Cross-cloud latency** (EigenCloud → AWS database = network overhead)
- ❌ **No Terraform support** (CLI-only deployment)
- ❌ **Limited documentation** (docs.eigencloud.xyz blocked/incomplete)
- ❌ **Unknown pricing** (alpha pricing not finalized)

**When to use:** Research/experimentation ONLY (not production MVP)

**Critical Finding:**
> EigenCloud is **NOT suitable for databases**. EigenDA provides "short-term storage" analogous to S3, NOT persistent block storage like AWS EBS. Database latency would be **10-15x slower** (50-200ms vs <1ms).

**Recommendation:**
- ❌ **DO NOT use for Phase 1 MVP** (too risky, alpha stage)
- ✅ **Research in parallel during Phase 4** (Week 6-7)
- ✅ **Consider for backend compute only** (keep database on AWS)
- 🔄 **Re-evaluate in Q4 2025** when EigenCompute exits alpha

---

## ✅ Prerequisites

### Required Tools

**For all options:**
- [ ] Git installed (`git --version`)
- [ ] Code editor (VSCode, Cursor, etc.)
- [ ] Terminal/PowerShell

**For Option A (Local Dev):**
- [ ] Docker Desktop installed (`docker --version`)
- [ ] Docker Compose installed (`docker-compose --version`)

**For Option B (AWS Prod):**
- [ ] AWS CLI installed (`aws --version`)
- [ ] AWS account with credentials configured (`aws configure`)
- [ ] Terraform installed (`terraform --version`)
- [ ] SSH client (for server access)

**For Option C (EigenCloud):**
- [ ] EigenCloud CLI installed (pending documentation - Q3 2025)
- [ ] EigenLayer testnet/mainnet wallet
- [ ] AWS account (for database hybrid deployment)

### Environment Setup

**Clone repository:**
```bash
git clone https://github.com/ultravioletadao/karmacadabra.git
cd karmacadabra/lighthouse
```

**Create .env file:**
```bash
cp .env.example .env
```

**Edit .env with your values:**
```bash
# Database (local)
DATABASE_URL=postgresql://lighthouse:lighthouse@localhost:5432/lighthouse

# Redis (local)
REDIS_URL=redis://localhost:6379

# USDC Payment Config (Avalanche Fuji testnet)
USDC_CONTRACT_ADDRESS=0x5425890298aed601595a70AB815c96711a31Bc65
RPC_URL_FUJI=https://api.avax-test.network/ext/bc/C/rpc
FACILITATOR_URL=https://facilitator.karmacadabra.ultravioletadao.xyz

# Secrets (DO NOT commit)
PRIVATE_KEY=  # Leave empty - fetched from AWS Secrets Manager in production
OPENAI_API_KEY=  # For canary workers (Phase 2)

# Alert Channels
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
```

---

## 📦 Option A: Local Development (Docker Compose)

### Step-by-Step (30 minutes)

#### **Step 1: Start Services (5 min)**

```bash
cd lighthouse
docker-compose up -d
```

**Expected output:**
```
Creating network "lighthouse_lighthouse" with the default driver
Creating volume "lighthouse_timescaledb-data" with default driver
Creating volume "lighthouse_redis-data" with default driver
Creating lighthouse-timescaledb ... done
Creating lighthouse-redis       ... done
Creating lighthouse-backend     ... done
Creating lighthouse-worker      ... done
```

**Verify containers running:**
```bash
docker-compose ps
```

Should show:
```
NAME                      STATUS         PORTS
lighthouse-backend        Up 10 seconds  0.0.0.0:8080->8080/tcp
lighthouse-timescaledb    Up 20 seconds  0.0.0.0:5432->5432/tcp
lighthouse-redis          Up 20 seconds  0.0.0.0:6379->6379/tcp
lighthouse-worker         Up 5 seconds
```

---

#### **Step 2: Verify Database (5 min)**

```bash
# Connect to TimescaleDB
docker exec -it lighthouse-timescaledb psql -U lighthouse -d lighthouse
```

**Check TimescaleDB extension:**
```sql
SELECT * FROM pg_extension WHERE extname = 'timescaledb';
```

**Should return:**
```
  extname   | extowner | extnamespace | extrelocatable | extversion
------------+----------+--------------+----------------+------------
 timescaledb |       10 |           14 | f              | 2.14.2
```

**Check if hypertables exist:**
```sql
SELECT * FROM timescaledb_information.hypertables;
```

**Exit psql:**
```
\q
```

---

#### **Step 3: Test Backend API (5 min)**

```bash
# Health check
curl http://localhost:8080/health

# Expected output:
# {"status":"ok","database":"connected","redis":"connected","timestamp":"2025-10-29T12:00:00Z"}
```

**Test metrics endpoint:**
```bash
curl http://localhost:9090/metrics
```

Should return Prometheus-format metrics.

---

#### **Step 4: Run Database Migrations (5 min)**

```bash
# Run migrations (creates tables, hypertables, indexes)
docker exec -it lighthouse-backend sqlx migrate run

# Or manually run migration files:
docker exec -i lighthouse-timescaledb psql -U lighthouse -d lighthouse < backend/migrations/001_initial_schema.sql
```

**Verify tables created:**
```bash
docker exec -it lighthouse-timescaledb psql -U lighthouse -d lighthouse -c "\dt"
```

**Should list:**
```
             List of relations
 Schema |       Name        | Type  |  Owner
--------+-------------------+-------+-----------
 public | subscriptions     | table | lighthouse
 public | check_history     | table | lighthouse
 public | canary_results    | table | lighthouse
 public | alerts            | table | lighthouse
 public | users             | table | lighthouse
```

---

#### **Step 5: Test Monitoring (5 min)**

**Create test subscription:**
```bash
curl -X POST http://localhost:8080/subscribe \
  -H "Content-Type: application/json" \
  -d '{
    "user_address": "0x1234567890123456789012345678901234567890",
    "target_type": "http",
    "target_config": {
      "url": "https://google.com",
      "method": "GET",
      "valid_status_codes": [200],
      "max_latency_ms": 5000
    },
    "tier": "free",
    "alert_channels": [
      {
        "type": "discord",
        "config": {"webhook_url": "YOUR_DISCORD_WEBHOOK"},
        "language": "en"
      }
    ],
    "payment_signature": "0x..."
  }'
```

**Expected response:**
```json
{
  "subscription_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "active",
  "next_check_at": "2025-10-29T12:05:00Z"
}
```

---

#### **Step 6: View Logs (5 min)**

```bash
# All services
docker-compose logs -f

# Backend only
docker-compose logs -f backend

# Database only
docker-compose logs -f timescaledb
```

**Press Ctrl+C to stop following logs**

---

#### **Step 7: Stop Services**

```bash
# Stop but preserve data
docker-compose stop

# Stop and remove containers (data persists in volumes)
docker-compose down

# DANGER: Remove everything including data
docker-compose down -v
```

---

### Local Development Workflow

**Daily development:**
```bash
# Start services
docker-compose up -d

# Edit code in lighthouse/backend/src/
# Rust backend auto-reloads (if using cargo-watch)

# View logs
docker-compose logs -f backend

# Restart specific service after changes
docker-compose restart backend

# Stop when done
docker-compose stop
```

---

## 🏗️ Option B: AWS Production (Terraform)

### Architecture Deployed

```
AWS Region: us-east-1
├── VPC (10.0.0.0/16)
│   ├── Public Subnet (10.0.1.0/24)
│   │   └── NAT Gateway (for private subnet internet access)
│   ├── Private Subnet (10.0.2.0/24)
│   │   ├── EC2 Instance (TimescaleDB)
│   │   │   ├── EBS Volume (100GB gp3, persistent)
│   │   │   └── Security Group (port 5432 from backend only)
│   │   └── EC2 Instance (Backend - optional separate instance)
│   │       └── Security Group (port 8080 from load balancer)
│   └── Load Balancer (optional)
│       └── Target Group → Backend instances
├── AWS Backup
│   └── Daily EBS snapshots (30-day retention)
├── CloudWatch
│   ├── Alarms (CPU >80%, Disk >85%)
│   └── Logs (application logs)
└── Secrets Manager
    └── Database credentials
```

### Step-by-Step (60 minutes)

#### **Step 1: AWS Account Setup (10 min)**

**Create AWS account** (if you don't have one):
- Go to https://aws.amazon.com/
- Sign up (requires credit card, free tier available)

**Configure AWS CLI:**
```bash
aws configure
```

**Enter:**
```
AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name: us-east-1
Default output format: json
```

**Verify:**
```bash
aws sts get-caller-identity
```

**Should return:**
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-name"
}
```

---

#### **Step 2: Create SSH Key Pair (5 min)**

```bash
# Create SSH key for EC2 access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/lighthouse-aws -C "lighthouse@ultravioletadao"

# Import to AWS
aws ec2 import-key-pair \
  --key-name lighthouse-prod \
  --public-key-material fileb://~/.ssh/lighthouse-aws.pub \
  --region us-east-1
```

---

#### **Step 3: Initialize Terraform (5 min)**

```bash
cd lighthouse/terraform/environments/prod
terraform init
```

**Expected output:**
```
Initializing modules...
Downloading git::https://github.com/terraform-aws-modules/terraform-aws-vpc

Initializing the backend...

Initializing provider plugins...
- Installing hashicorp/aws v5.30.0...

Terraform has been successfully initialized!
```

---

#### **Step 4: Configure Variables (10 min)**

**Edit `terraform.tfvars`:**
```bash
cd lighthouse/terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # or vim, code, etc.
```

**Required variables:**
```hcl
# Project
project_name = "lighthouse-prod"
environment  = "production"

# Database
db_instance_type = "t4g.small"    # ARM Graviton2 (cheaper)
db_volume_size   = 100            # GB
db_password      = "CHANGE_ME_STRONG_PASSWORD"

# Backups
backup_retention_days = 30
enable_cross_region_backup = false  # Set true for DR

# Monitoring
cloudwatch_alarm_email = "alerts@ultravioletadao.xyz"

# Networking
allowed_cidr_blocks = ["10.0.0.0/16"]  # Backend subnet only
enable_public_access = false            # Database in private subnet

# SSH Access (for troubleshooting)
ssh_key_name = "lighthouse-prod"
enable_bastion = true  # Bastion host for SSH access
```

---

#### **Step 5: Plan Deployment (5 min)**

```bash
terraform plan -out=tfplan
```

**Review output carefully:**
```
Plan: 23 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + database_endpoint = (known after apply)
  + database_connection_string = (sensitive value)
  + instance_id = (known after apply)
  + backup_vault_arn = (known after apply)
  + cloudwatch_dashboard_url = (known after apply)

Estimated monthly cost: $22.43
```

**Verify:**
- ✅ VPC and subnets created
- ✅ EC2 instance type is t4g.small (not expensive t3.large)
- ✅ EBS volume is gp3 (cheaper than io1)
- ✅ Backup plan enabled
- ✅ Security groups restrict access

---

#### **Step 6: Deploy Infrastructure (15 min)**

```bash
terraform apply tfplan
```

**Terraform will:**
1. Create VPC (1 min)
2. Create subnets, route tables, NAT gateway (2 min)
3. Launch EC2 instance (3 min)
4. Create and attach EBS volume (2 min)
5. Run user_data.sh bootstrap script (5 min)
   - Install Docker
   - Mount EBS volume
   - Start TimescaleDB container
6. Configure AWS Backup (1 min)
7. Create CloudWatch alarms (1 min)

**Total: ~15 minutes**

**Watch instance initialization:**
```bash
# Get instance ID from Terraform output
INSTANCE_ID=$(terraform output -raw instance_id)

# Watch system log
aws ec2 get-console-output --instance-id $INSTANCE_ID
```

---

#### **Step 7: Verify Deployment (10 min)**

**Get database endpoint:**
```bash
terraform output database_endpoint
# Output: 10.0.2.123:5432
```

**SSH to instance (via bastion):**
```bash
BASTION_IP=$(terraform output -raw bastion_public_ip)
DB_PRIVATE_IP=$(terraform output -raw database_private_ip)

# SSH to bastion
ssh -i ~/.ssh/lighthouse-aws ec2-user@$BASTION_IP

# From bastion, SSH to database server
ssh 10.0.2.123
```

**Verify TimescaleDB running:**
```bash
docker ps
# Should show timescaledb container

docker logs timescaledb
# Should show "database system is ready to accept connections"
```

**Test database connection:**
```bash
psql postgresql://lighthouse:PASSWORD@localhost:5432/lighthouse -c "SELECT version();"
```

**Check EBS volume mounted:**
```bash
df -h | grep timescaledb
# /dev/nvme1n1   100G   1.2G   94G   2%   /mnt/timescaledb-data
```

**Exit SSH:**
```bash
exit  # exit from DB server
exit  # exit from bastion
```

---

#### **Step 8: Deploy Backend Application (Optional - Phase 2)**

**If deploying backend on separate EC2:**

Edit `terraform.tfvars`:
```hcl
deploy_backend = true
backend_instance_type = "t4g.small"
backend_instance_count = 2  # For load balancing
```

**Apply changes:**
```bash
terraform plan
terraform apply
```

**Deploy application code:**
```bash
# Build Docker image locally
cd lighthouse/backend
docker build -t lighthouse-backend:latest .

# Push to ECR (Elastic Container Registry)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
docker tag lighthouse-backend:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/lighthouse-backend:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/lighthouse-backend:latest

# SSH to backend instance and pull image
ssh -i ~/.ssh/lighthouse-aws ec2-user@BACKEND_IP
docker pull 123456789012.dkr.ecr.us-east-1.amazonaws.com/lighthouse-backend:latest
docker run -d \
  -e DATABASE_URL=postgresql://lighthouse:PASSWORD@10.0.2.123:5432/lighthouse \
  -e REDIS_URL=redis://localhost:6379 \
  -p 8080:8080 \
  --name lighthouse-backend \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/lighthouse-backend:latest
```

---

#### **Step 9: Configure Monitoring (10 min)**

**View CloudWatch Dashboard:**
```bash
terraform output cloudwatch_dashboard_url
# https://console.aws.amazon.com/cloudwatch/...
```

**Dashboard includes:**
- CPU utilization (alarm at >80%)
- Disk usage (alarm at >85%)
- Memory usage (via CloudWatch agent)
- Network I/O
- Database connections

**Set up SNS email alerts:**
```bash
# Subscribe to alarm topic
aws sns subscribe \
  --topic-arn $(terraform output -raw alarm_topic_arn) \
  --protocol email \
  --notification-endpoint alerts@ultravioletadao.xyz

# Confirm subscription via email link
```

---

### AWS Production Workflow

**Daily operations:**
```bash
# View logs
aws logs tail /aws/ec2/lighthouse-database --follow

# SSH for troubleshooting
ssh -i ~/.ssh/lighthouse-aws -J bastion ec2-user@DB_PRIVATE_IP

# Scale up instance
# Edit terraform.tfvars: db_instance_type = "t4g.medium"
terraform plan
terraform apply
# Downtime: ~2 minutes

# Manual backup
aws backup start-backup-job \
  --backup-vault-name lighthouse-prod-vault \
  --resource-arn $(terraform output -raw volume_arn)

# Restore from backup (disaster recovery)
# 1. Find backup ARN
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name lighthouse-prod-vault

# 2. Restore to new volume
aws backup start-restore-job \
  --recovery-point-arn arn:aws:backup:... \
  --metadata file://restore-metadata.json
```

---

## 🔬 Option C: EigenCloud Hybrid (Research)

### ⚠️ WARNING: Not Ready for Production

**Current Status (October 2025):**
- EigenCompute: **Mainnet ALPHA**
- EigenDA: Mainnet live (data availability only)
- Documentation: Partially blocked/incomplete
- Pricing: Alpha pricing, not finalized
- Terraform/SDK: **NOT available** (CLI only)

**Do NOT use for MVP. Research only.**

---

### Research Plan (Phase 4 - Week 6)

#### **Day 1: Documentation Review**

**Objective:** Understand EigenCloud capabilities

**Tasks:**
1. Access docs.eigencloud.xyz (request access if blocked)
2. Read EigenCompute quickstart guide
3. Identify:
   - Supported runtimes (Docker? Rust native?)
   - Storage options (EigenDA capabilities)
   - Networking (can it call external AWS database?)
   - Pricing model (per-hour? per-request?)
   - CLI commands for deployment

**Deliverable:** `lighthouse/research/eigencloud-capabilities.md`

---

#### **Day 2: CLI Installation & Auth**

**Objective:** Install EigenCloud CLI and authenticate

**Tasks:**
```bash
# Install CLI (check docs for latest method)
npm install -g @eigencloud/cli
# or
curl -sSL https://eigencloud.xyz/install.sh | bash

# Verify installation
eigencloud --version

# Authenticate (likely requires EigenLayer wallet)
eigencloud login
# Follow prompts (MetaMask signature? Private key?)

# List available commands
eigencloud help
```

**Deliverable:** CLI installed, authenticated, command list documented

---

#### **Day 3: Deploy Test Backend**

**Objective:** Deploy simple Rust backend to EigenCloud

**Tasks:**
1. Create minimal Rust HTTP server
2. Build Docker image
3. Deploy to EigenCloud via CLI

**Test app (main.rs):**
```rust
use axum::{routing::get, Router};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/health", get(|| async { "OK" }));

    axum::Server::bind(&"0.0.0.0:8080".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

**Deploy:**
```bash
# Build Docker image
docker build -t lighthouse-test .

# Deploy to EigenCloud (hypothetical CLI syntax)
eigencloud deploy \
  --image lighthouse-test:latest \
  --name lighthouse-backend-test \
  --port 8080 \
  --env DATABASE_URL=postgresql://user@aws-db-ip:5432/db

# Get deployment URL
eigencloud apps list
# https://lighthouse-backend-test.eigencloud.app or similar
```

**Test:**
```bash
curl https://lighthouse-backend-test.eigencloud.app/health
# Expected: "OK"
```

**Deliverable:** Working EigenCloud deployment, document CLI commands

---

#### **Day 4: Test Cross-Cloud Database Access**

**Objective:** Measure latency from EigenCloud → AWS database

**Tasks:**
1. Deploy AWS EC2 TimescaleDB (using Terraform from Option B)
2. Configure security group to allow EigenCloud IP ranges
3. Test database connection from EigenCloud backend

**Test endpoint (add to Rust app):**
```rust
.route("/test-db", get(|| async {
    let start = std::time::Instant::now();

    // Query database
    let pool = PgPoolOptions::new()
        .connect(&DATABASE_URL)
        .await?;

    let result: i32 = sqlx::query_scalar("SELECT 1")
        .fetch_one(&pool)
        .await?;

    let latency_ms = start.elapsed().as_millis();

    format!("DB returned {}, latency: {}ms", result, latency_ms)
}))
```

**Benchmark:**
```bash
# Run 100 requests
for i in {1..100}; do
  curl https://lighthouse-backend-test.eigencloud.app/test-db
done | grep "latency" | awk '{sum+=$NF; count++} END {print "Avg:", sum/count, "ms"}'
```

**Expected results:**
- AWS EC2 → AWS RDS: 1-5ms
- EigenCloud → AWS RDS: 50-200ms (10-40x slower)

**Deliverable:** Latency benchmarks, decision on feasibility

---

#### **Day 5: Cost Analysis**

**Objective:** Compare actual costs

**Tasks:**
1. Run backend on EigenCloud for 24 hours
2. Check billing/usage dashboard
3. Compare with AWS EC2 equivalent

**Hypothetical pricing:**
```
EigenCloud:
- Compute: $0.01/hour * 24 hours = $0.24/day = $7.20/month
- Network egress: $0.05/GB * 10GB = $0.50/month
- EigenDA storage: $0.10/GB/month * 1GB = $0.10/month
Total: ~$8/month

AWS EC2 t4g.small:
- Compute: $0.0168/hour * 730 hours = $12.26/month
- EBS storage: $0.08/GB/month * 20GB = $1.60/month
- Network egress: $0.09/GB * 10GB = $0.90/month
Total: ~$15/month

Savings: $7/month (47%)
```

**BUT consider:**
- Database must stay on AWS (can't use EigenCloud)
- Cross-cloud networking costs
- Alpha pricing may change

**Deliverable:** `lighthouse/research/eigencloud-cost-analysis.md`

---

#### **Day 6: Verifiability Testing**

**Objective:** Understand verifiable compute benefits

**Tasks:**
1. Deploy monitoring check that records on-chain proof
2. Verify proof can be validated by third party
3. Assess if users value this feature (survey Web3 communities)

**Example:**
```bash
# Run monitoring check
eigencloud run-job \
  --job-id check-google-health \
  --proof-to 0xSMARTCONTRACT_ADDRESS

# Job runs, records proof on-chain via EigenDA
# Proof includes: timestamp, result, execution hash

# Anyone can verify:
eigencloud verify-proof \
  --job-id check-google-health \
  --timestamp 2025-10-29T12:00:00Z
# Returns: "Proof valid. Google returned 200 at 12:00:00 UTC"
```

**Value proposition:**
- User can PROVE to third party that monitoring happened
- Trustless audit trail (can't fake downtime reports)
- Useful for SLAs, insurance claims, dispute resolution

**Deliverable:** Proof-of-concept, user feedback survey results

---

#### **Day 7: Decision & Documentation**

**Objective:** Go/No-Go decision on EigenCloud

**Criteria:**

| Factor | Weight | Score (1-10) | Notes |
|--------|--------|--------------|-------|
| **Database support** | 30% | ? | Can we run TimescaleDB? Latency acceptable? |
| **Cost savings** | 25% | ? | Actual savings vs AWS (accounting for DB on AWS) |
| **Reliability** | 20% | ? | Uptime during alpha testing? |
| **Documentation** | 15% | ? | Sufficient docs to deploy production? |
| **Verifiability value** | 10% | ? | Do users care about on-chain proofs? |

**Decision matrix:**
```
Total weighted score >= 7.0: ✅ Migrate backend to EigenCloud (Phase 5)
Score 5.0-6.9: ⚠️ Hybrid deployment for premium tier only
Score < 5.0: ❌ Stay on AWS, revisit in 6 months
```

**Deliverables:**
1. `lighthouse/research/eigencloud-decision.md`
2. Update `lighthouse-master-plan.md` with findings
3. If proceeding: Create `lighthouse/terraform/eigencloud/` deployment scripts
4. If not proceeding: Archive research, set reminder for Q1 2026

---

### EigenCloud Deployment (If Approved)

**Hypothetical workflow (pending research findings):**

```bash
# 1. Build and push Docker image
cd lighthouse/backend
docker build -t lighthouse-backend:v1.0.0 .

# 2. Push to EigenCloud registry
eigencloud images push lighthouse-backend:v1.0.0

# 3. Deploy with environment variables
eigencloud deploy \
  --image lighthouse-backend:v1.0.0 \
  --name lighthouse-prod \
  --replicas 2 \
  --env-file .env.eigencloud \
  --port 8080 \
  --domain lighthouse.ultravioletadao.xyz \
  --ssl-certificate auto

# 4. Configure database connection (AWS)
eigencloud config set DATABASE_URL "postgresql://user@aws-rds-endpoint:5432/lighthouse"

# 5. Monitor deployment
eigencloud logs --app lighthouse-prod --follow

# 6. Verify health
curl https://lighthouse.ultravioletadao.xyz/health
```

**Database remains on AWS:**
```bash
# Terraform deploys ONLY database, not backend
cd lighthouse/terraform/environments/prod
terraform apply -target=module.timescaledb
```

---

## 📅 Phase-by-Phase Roadmap

### Overview

```
Phase 1 (Week 1-2): MVP - Local Dev → AWS Deploy
Phase 2 (Week 3-4): Canary Flows + Standard Tier
Phase 3 (Week 5): Blockchain Monitoring + Pro Tier
Phase 4 (Week 6-7): EigenCloud Research + Multi-Channel Alerts
Phase 5 (Week 8): Polish + Public Launch
```

---

### Phase 1: MVP (2 Weeks) - DETAILED BREAKDOWN

#### **Week 1: Core Infrastructure**

##### **Day 1 (Monday): Project Setup + Local Dev**

**Time:** 8 hours

**Morning (4 hours):**
1. ✅ Initialize Git repository structure
   ```bash
   mkdir -p lighthouse/{backend,workers,frontend,terraform,docs}
   cd lighthouse/backend
   cargo init --name lighthouse
   ```

2. ✅ Add dependencies to Cargo.toml
   ```toml
   [dependencies]
   axum = "0.7"
   tokio = { version = "1", features = ["full"] }
   sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres", "uuid", "chrono"] }
   redis = { version = "0.24", features = ["tokio-comp"] }
   reqwest = { version = "0.11", features = ["json"] }
   serde = { version = "1.0", features = ["derive"] }
   serde_json = "1.0"
   chrono = { version = "0.4", features = ["serde"] }
   uuid = { version = "1.0", features = ["serde", "v4"] }
   tower-http = { version = "0.5", features = ["trace", "cors"] }
   tracing = "0.1"
   tracing-subscriber = "0.3"
   ```

3. ✅ Create project structure
   ```bash
   mkdir -p src/{api,db,monitors,scheduler,alerts,payments}
   touch src/{main.rs,config.rs,error.rs}
   touch src/api/{mod.rs,routes.rs,handlers.rs}
   touch src/db/{mod.rs,models.rs,queries.rs}
   touch src/monitors/{mod.rs,http.rs}
   touch src/scheduler/{mod.rs}
   touch src/alerts/{mod.rs,discord.rs}
   touch src/payments/{mod.rs,usdc.rs,x402.rs}
   ```

4. ✅ Set up Docker Compose (already created, verify it works)
   ```bash
   docker-compose up -d timescaledb redis
   docker-compose ps  # Verify running
   ```

**Afternoon (4 hours):**
5. ✅ Create `src/main.rs` skeleton
   ```rust
   use axum::{Router, routing::get};
   use std::net::SocketAddr;

   #[tokio::main]
   async fn main() {
       tracing_subscriber::fmt::init();

       let app = Router::new()
           .route("/health", get(health_check));

       let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
       tracing::info!("Listening on {}", addr);

       axum::Server::bind(&addr)
           .serve(app.into_make_service())
           .await
           .unwrap();
   }

   async fn health_check() -> &'static str {
       "OK"
   }
   ```

6. ✅ Test basic server
   ```bash
   cargo run
   # In another terminal:
   curl http://localhost:8080/health
   # Should return: OK
   ```

7. ✅ Create `src/config.rs` for environment variables
   ```rust
   use std::env;

   #[derive(Clone)]
   pub struct Config {
       pub database_url: String,
       pub redis_url: String,
       pub port: u16,
   }

   impl Config {
       pub fn from_env() -> Self {
           Self {
               database_url: env::var("DATABASE_URL")
                   .expect("DATABASE_URL must be set"),
               redis_url: env::var("REDIS_URL")
                   .unwrap_or_else(|_| "redis://localhost:6379".to_string()),
               port: env::var("PORT")
                   .unwrap_or_else(|_| "8080".to_string())
                   .parse()
                   .expect("PORT must be a number"),
           }
       }
   }
   ```

8. ✅ Document day's progress in `docs/PROGRESS.md`

**Deliverables:**
- ✅ Rust project structure
- ✅ Basic HTTP server running on :8080
- ✅ Docker Compose with TimescaleDB + Redis
- ✅ Health check endpoint

---

##### **Day 2 (Tuesday): Database Setup + Migrations**

**Time:** 8 hours

**Morning (4 hours):**
1. ✅ Install sqlx-cli
   ```bash
   cargo install sqlx-cli --no-default-features --features postgres
   ```

2. ✅ Create database
   ```bash
   sqlx database create --database-url postgresql://lighthouse:lighthouse@localhost:5432/lighthouse
   ```

3. ✅ Create migration: Initial schema
   ```bash
   sqlx migrate add initial_schema
   ```

4. ✅ Edit `migrations/XXXXXX_initial_schema.sql`
   ```sql
   -- Enable TimescaleDB extension
   CREATE EXTENSION IF NOT EXISTS timescaledb;

   -- Subscriptions table (relational)
   CREATE TABLE subscriptions (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       user_address TEXT NOT NULL,
       target_type TEXT NOT NULL,
       target_config JSONB NOT NULL,
       tier TEXT NOT NULL,
       check_frequency_seconds INT NOT NULL,
       alert_channels JSONB,
       created_at TIMESTAMPTZ DEFAULT NOW(),
       expires_at TIMESTAMPTZ,
       active BOOLEAN DEFAULT TRUE,
       payment_tx TEXT,
       payment_chain TEXT,
       last_check_at TIMESTAMPTZ,
       next_check_at TIMESTAMPTZ,
       consecutive_failures INT DEFAULT 0,
       total_alerts_sent INT DEFAULT 0
   );

   CREATE INDEX idx_subscriptions_active ON subscriptions(active, next_check_at);
   CREATE INDEX idx_subscriptions_user ON subscriptions(user_address);

   -- Check history (TimescaleDB hypertable)
   CREATE TABLE check_history (
       time TIMESTAMPTZ NOT NULL,
       subscription_id UUID NOT NULL REFERENCES subscriptions(id),
       status TEXT NOT NULL,
       http_status INT,
       response_time_ms INT,
       timings JSONB,
       error_message TEXT,
       response_body TEXT,
       state_change BOOLEAN DEFAULT FALSE,
       alert_triggered BOOLEAN DEFAULT FALSE
   );

   SELECT create_hypertable('check_history', 'time');

   -- Compression
   ALTER TABLE check_history SET (
       timescaledb.compress,
       timescaledb.compress_segmentby = 'subscription_id'
   );

   SELECT add_compression_policy('check_history', INTERVAL '7 days');
   SELECT add_retention_policy('check_history', INTERVAL '90 days');

   -- Continuous aggregate for hourly metrics
   CREATE MATERIALIZED VIEW hourly_metrics
   WITH (timescaledb.continuous) AS
   SELECT
       subscription_id,
       time_bucket('1 hour', time) AS hour,
       COUNT(*) as total_checks,
       COUNT(*) FILTER (WHERE status = 'success') as successful_checks,
       COUNT(*) FILTER (WHERE status != 'success') as failed_checks,
       AVG(response_time_ms) as avg_latency_ms,
       MAX(response_time_ms) as max_latency_ms,
       MIN(response_time_ms) as min_latency_ms,
       (COUNT(*) FILTER (WHERE status = 'success') * 100.0 / COUNT(*)) as uptime_pct
   FROM check_history
   GROUP BY subscription_id, hour;

   SELECT add_continuous_aggregate_policy('hourly_metrics',
       start_offset => INTERVAL '3 hours',
       end_offset => INTERVAL '1 hour',
       schedule_interval => INTERVAL '1 hour');

   -- Alerts table
   CREATE TABLE alerts (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       subscription_id UUID NOT NULL REFERENCES subscriptions(id),
       check_time TIMESTAMPTZ,
       alert_type TEXT NOT NULL,
       severity TEXT NOT NULL,
       message TEXT,
       timestamp TIMESTAMPTZ DEFAULT NOW(),
       channels_sent TEXT[],
       delivery_status JSONB,
       retry_count INT DEFAULT 0,
       language TEXT DEFAULT 'en'
   );

   CREATE INDEX idx_alerts_subscription ON alerts(subscription_id, timestamp DESC);

   -- Users table (optional)
   CREATE TABLE users (
       wallet_address TEXT PRIMARY KEY,
       email TEXT,
       created_at TIMESTAMPTZ DEFAULT NOW(),
       subscription_count INT DEFAULT 0,
       total_spent_usdc NUMERIC(18, 6),
       language_preference TEXT DEFAULT 'en'
   );
   ```

5. ✅ Run migrations
   ```bash
   sqlx migrate run
   ```

6. ✅ Verify schema
   ```bash
   psql postgresql://lighthouse:lighthouse@localhost:5432/lighthouse -c "\dt"
   ```

**Afternoon (4 hours):**
7. ✅ Create Rust database models (`src/db/models.rs`)
   ```rust
   use chrono::{DateTime, Utc};
   use serde::{Deserialize, Serialize};
   use sqlx::types::Uuid;
   use sqlx::FromRow;

   #[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
   pub struct Subscription {
       pub id: Uuid,
       pub user_address: String,
       pub target_type: String,
       pub target_config: serde_json::Value,
       pub tier: String,
       pub check_frequency_seconds: i32,
       pub alert_channels: Option<serde_json::Value>,
       pub created_at: DateTime<Utc>,
       pub expires_at: Option<DateTime<Utc>>,
       pub active: bool,
       pub payment_tx: Option<String>,
       pub payment_chain: Option<String>,
       pub last_check_at: Option<DateTime<Utc>>,
       pub next_check_at: Option<DateTime<Utc>>,
       pub consecutive_failures: i32,
       pub total_alerts_sent: i32,
   }

   #[derive(Debug, Clone, Serialize, Deserialize)]
   pub struct CheckResult {
       pub subscription_id: Uuid,
       pub status: String,
       pub http_status: Option<i32>,
       pub response_time_ms: Option<i32>,
       pub timings: Option<serde_json::Value>,
       pub error_message: Option<String>,
       pub response_body: Option<String>,
       pub state_change: bool,
       pub alert_triggered: bool,
   }
   ```

8. ✅ Create database connection pool (`src/db/mod.rs`)
   ```rust
   use sqlx::{postgres::PgPoolOptions, PgPool};
   use std::time::Duration;

   pub mod models;
   pub mod queries;

   pub async fn create_pool(database_url: &str) -> Result<PgPool, sqlx::Error> {
       PgPoolOptions::new()
           .max_connections(20)
           .min_connections(5)
           .acquire_timeout(Duration::from_secs(30))
           .connect(database_url)
           .await
   }
   ```

9. ✅ Test database connection in main.rs
   ```rust
   use lighthouse::db;

   #[tokio::main]
   async fn main() {
       let config = Config::from_env();
       let pool = db::create_pool(&config.database_url)
           .await
           .expect("Failed to connect to database");

       tracing::info!("Database connected");

       // ... rest of server setup
   }
   ```

10. ✅ Write basic queries (`src/db/queries.rs`)
    ```rust
    use sqlx::PgPool;
    use crate::db::models::Subscription;

    pub async fn get_active_subscriptions(pool: &PgPool) -> Result<Vec<Subscription>, sqlx::Error> {
        sqlx::query_as::<_, Subscription>(
            "SELECT * FROM subscriptions WHERE active = true AND next_check_at <= NOW() LIMIT 100"
        )
        .fetch_all(pool)
        .await
    }

    pub async fn insert_check_result(
        pool: &PgPool,
        result: &CheckResult,
    ) -> Result<(), sqlx::Error> {
        sqlx::query(
            "INSERT INTO check_history (time, subscription_id, status, http_status, response_time_ms, timings, error_message, response_body, state_change, alert_triggered)
             VALUES (NOW(), $1, $2, $3, $4, $5, $6, $7, $8, $9)"
        )
        .bind(&result.subscription_id)
        .bind(&result.status)
        .bind(&result.http_status)
        .bind(&result.response_time_ms)
        .bind(&result.timings)
        .bind(&result.error_message)
        .bind(&result.response_body)
        .bind(&result.state_change)
        .bind(&result.alert_triggered)
        .execute(pool)
        .await?;

        Ok(())
    }
    ```

**Deliverables:**
- ✅ Database schema with TimescaleDB hypertables
- ✅ Rust models + sqlx integration
- ✅ Database connection pool
- ✅ Basic CRUD queries

---

(Continuing with Week 1, Days 3-5 and Week 2 in next message due to length...)

Would you like me to continue with the complete granular breakdown of all 8 weeks, or would you prefer I create this as a comprehensive document and add it to the master plan?