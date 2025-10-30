# ============================================================================
# Lighthouse Production Environment - TimescaleDB
# ============================================================================
# Cost: ~$22/month (t4g.small + 100GB storage + backups + monitoring)
# Use case: Production workload (500-2,000 subscriptions)
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 backend for state management (REQUIRED for production)
  backend "s3" {
    bucket         = "lighthouse-terraform-state"
    key            = "prod/timescaledb/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "lighthouse-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Lighthouse"
      Environment = "production"
      ManagedBy   = "Terraform"
      CostCenter  = "infrastructure"
    }
  }
}

# ============================================================================
# Data Sources
# ============================================================================

# VPC and networking (assumes pre-existing VPC setup)
data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "private" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = var.private_subnet_name
    Tier = "private"
  }
}

# Backend security group (for database access)
data "aws_security_group" "backend" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = var.backend_security_group_name
  }
}

# Route53 zone for DNS
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# Secrets Manager for database password
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret_id
}

# SNS topic for CloudWatch alarms
data "aws_sns_topic" "alerts" {
  name = var.alerts_sns_topic_name
}

# ============================================================================
# TimescaleDB Module
# ============================================================================

module "timescaledb" {
  source = "../../modules/timescaledb-ec2"

  name_prefix = "lighthouse-prod"
  vpc_id      = data.aws_vpc.main.id
  subnet_id   = data.aws_subnet.private.id

  # PRODUCTION INSTANCE (on-demand, reliable)
  instance_type     = var.instance_type
  use_spot_instance = false  # Never use spot in production
  volume_size_gb    = var.volume_size_gb
  volume_type       = "gp3"
  volume_iops       = 3000  # Default, no extra cost
  volume_encrypted  = true  # Encryption at rest

  # PRIVATE SUBNET (no public IP)
  associate_public_ip = false

  # STRICT SECURITY (backend only)
  allowed_security_groups = [data.aws_security_group.backend.id]
  allowed_cidr_blocks     = []  # Deny all except backend
  enable_ssh_access       = true
  key_name                = var.ssh_key_name
  ssh_cidr_blocks         = var.ssh_allowed_cidr_blocks  # Bastion or VPN only

  # Database configuration
  postgres_password = data.aws_secretsmanager_secret_version.db_password.secret_string
  database_name     = "lighthouse"
  postgres_version  = "16"
  timescaledb_image = "timescale/timescaledb:latest-pg16"

  # PRODUCTION BACKUPS
  enable_automated_backups = true
  backup_retention_days    = 30  # 30-day retention
  backup_schedule          = "cron(0 2 * * ? *)"  # 2 AM UTC daily
  backup_s3_bucket         = var.backup_s3_bucket

  # FULL MONITORING
  enable_monitoring     = true
  cpu_alarm_threshold   = 80
  disk_alarm_threshold  = 85
  alarm_sns_topic_arn   = data.aws_sns_topic.alerts.arn

  # DNS RECORD
  create_dns_record = true
  route53_zone_id   = data.aws_route53_zone.main.zone_id
  dns_name          = "db.${var.domain_name}"

  tags = {
    Environment = "production"
    Backup      = "critical"
    Compliance  = "required"
  }
}

# ============================================================================
# CloudWatch Dashboard
# ============================================================================

resource "aws_cloudwatch_dashboard" "timescaledb" {
  dashboard_name = "lighthouse-prod-timescaledb"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average", label = "CPU Usage" }],
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Database CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["CWAgent", "disk_used_percent", { stat = "Average", label = "Disk Usage" }],
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Database Disk Usage"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "StatusCheckFailed", { stat = "Maximum", label = "Status Check Failed" }],
          ]
          period = 60
          stat   = "Maximum"
          region = var.aws_region
          title  = "Instance Health"
        }
      }
    ]
  })
}

# ============================================================================
# Backup Verification Lambda (Optional)
# ============================================================================

# Lambda function to verify backups are restorable
# (Runs weekly, restores latest snapshot to test instance)
# See: docs/BACKUP_VERIFICATION_LAMBDA.md

# ============================================================================
# Outputs
# ============================================================================

output "database_endpoint" {
  description = "Database connection endpoint (internal DNS)"
  value       = module.timescaledb.database_endpoint
}

output "database_connection_string" {
  description = "PostgreSQL connection string (sensitive)"
  value       = module.timescaledb.database_connection_string
  sensitive   = true
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.timescaledb.instance_id
}

output "instance_private_ip" {
  description = "Private IP address"
  value       = module.timescaledb.instance_private_ip
}

output "volume_id" {
  description = "EBS volume ID"
  value       = module.timescaledb.volume_id
}

output "security_group_id" {
  description = "Database security group ID"
  value       = module.timescaledb.security_group_id
}

output "backup_vault_arn" {
  description = "AWS Backup vault ARN"
  value       = module.timescaledb.backup_vault_arn
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.timescaledb.dashboard_name}"
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost (USD)"
  value       = module.timescaledb.estimated_monthly_cost_usd
}

# ============================================================================
# Deployment Instructions
# ============================================================================

output "deployment_instructions" {
  description = "Post-deployment steps"
  value       = <<-EOT

  Production TimescaleDB Deployed Successfully!

  ============================================
  CRITICAL: Run these steps before going live
  ============================================

  1. Verify database connection (from backend):
     export DATABASE_URL="${module.timescaledb.database_connection_string}"
     psql $DATABASE_URL -c "SELECT version();"

  2. Run database migrations:
     cd lighthouse/backend
     sqlx migrate run

  3. Verify TimescaleDB extension:
     psql $DATABASE_URL -c "SELECT extversion FROM pg_extension WHERE extname='timescaledb';"

  4. Create hypertables and aggregates:
     psql $DATABASE_URL < migrations/002_timescaledb_setup.sql

  5. Test backup restoration (critical!):
     aws backup start-restore-job \
       --recovery-point-arn <latest-snapshot-arn> \
       --metadata file://restore-metadata.json

  6. Configure application connection string:
     Update backend environment variable:
     DATABASE_URL=${module.timescaledb.database_endpoint}:5432/lighthouse

  7. Set up monitoring alerts:
     CloudWatch Dashboard: ${aws_cloudwatch_dashboard.timescaledb.dashboard_name}
     SNS Topic: ${data.aws_sns_topic.alerts.arn}

  8. Schedule weekly backup verification:
     (Manual process or Lambda - see docs/BACKUP_VERIFICATION.md)

  ============================================
  Cost Information
  ============================================

  Estimated monthly cost: ${module.timescaledb.estimated_monthly_cost_usd}

  Breakdown:
  - EC2 instance (${var.instance_type}): ~$${var.instance_type == "t4g.small" ? "12" : var.instance_type == "t4g.medium" ? "24" : "6"}/month
  - EBS volume (${var.volume_size_gb} GB): ~$${var.volume_size_gb * 0.08}/month
  - Snapshots (~${var.volume_size_gb * 0.1} GB): ~$${var.volume_size_gb * 0.1 * 0.05}/month
  - CloudWatch: ~$2/month

  ============================================
  SSH Access (Bastion/VPN only)
  ============================================

  Instance is in private subnet. Use bastion host or VPN:

  1. Via bastion:
     ssh -J bastion-host ubuntu@${module.timescaledb.instance_private_ip}

  2. Via AWS Systems Manager (no SSH key needed):
     aws ssm start-session --target ${module.timescaledb.instance_id}

  ============================================
  Next Steps
  ============================================

  - Update backend deployment with DATABASE_URL
  - Run load testing (simulate 1,000 subscriptions)
  - Monitor CloudWatch dashboard for 24 hours
  - Test failover procedure (stop instance, verify recovery)
  - Document runbooks for common operations

  EOT
}
