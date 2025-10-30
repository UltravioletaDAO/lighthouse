# ============================================================================
# Lighthouse Development Environment - TimescaleDB
# ============================================================================
# Cost: ~$4/month (spot instance + minimal storage)
# Use case: Local development, testing migrations, CI/CD
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Optional: Use S3 backend for team collaboration
  # backend "s3" {
  #   bucket = "lighthouse-terraform-state"
  #   key    = "dev/timescaledb/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Lighthouse"
      Environment = "development"
      ManagedBy   = "Terraform"
      CostCenter  = "development"
    }
  }
}

# ============================================================================
# Data Sources
# ============================================================================

# Use default VPC for dev (or specify existing VPC)
data "aws_vpc" "default" {
  default = true
}

# Get public subnet in first AZ
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# ============================================================================
# Random Password (Development Only - Use Secrets Manager in Production)
# ============================================================================

resource "random_password" "db_password" {
  length  = 24
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store in SSM Parameter Store (free, simple for dev)
resource "aws_ssm_parameter" "db_password" {
  name        = "/lighthouse/dev/db/password"
  description = "TimescaleDB password for development"
  type        = "SecureString"
  value       = random_password.db_password.result

  tags = {
    Environment = "development"
  }
}

# ============================================================================
# TimescaleDB Module
# ============================================================================

module "timescaledb" {
  source = "../../modules/timescaledb-ec2"

  name_prefix = "lighthouse-dev"
  vpc_id      = data.aws_vpc.default.id
  subnet_id   = data.aws_subnets.public.ids[0]

  # MINIMAL INSTANCE (spot for cost savings)
  instance_type     = "t4g.micro"
  use_spot_instance = true  # 70-90% discount
  volume_size_gb    = 20    # Minimum size
  volume_type       = "gp3"

  # Public IP for easy SSH access (dev only)
  associate_public_ip = true

  # RELAXED SECURITY (dev environment)
  allowed_cidr_blocks = [data.aws_vpc.default.cidr_block]  # Entire VPC
  enable_ssh_access   = true
  key_name            = var.ssh_key_name
  ssh_cidr_blocks     = ["0.0.0.0/0"]  # WARNING: Restrict in production

  # Database configuration
  postgres_password = random_password.db_password.result
  database_name     = "lighthouse_dev"
  postgres_version  = "16"

  # MINIMAL BACKUPS (dev environment)
  enable_automated_backups = true
  backup_retention_days    = 7  # 1 week only
  backup_schedule          = "cron(0 3 * * ? *)"  # 3 AM UTC

  # DISABLE MONITORING (save $2/month)
  enable_monitoring = false

  tags = {
    Environment = "development"
    AutoShutdown = "yes"  # Can be shut down at night to save costs
  }
}

# ============================================================================
# Outputs
# ============================================================================

output "database_endpoint" {
  description = "Database connection endpoint"
  value       = module.timescaledb.database_endpoint
}

output "database_connection_string" {
  description = "PostgreSQL connection string"
  value       = module.timescaledb.database_connection_string
  sensitive   = true
}

output "instance_public_ip" {
  description = "Public IP for SSH access"
  value       = module.timescaledb.instance_public_ip
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${module.timescaledb.instance_public_ip}"
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost (USD)"
  value       = module.timescaledb.estimated_monthly_cost_usd
}

# ============================================================================
# Usage Instructions
# ============================================================================

output "usage_instructions" {
  description = "How to use this environment"
  value       = <<-EOT

  Development Environment Deployed!

  1. Get database password:
     aws ssm get-parameter --name /lighthouse/dev/db/password --with-decryption --query 'Parameter.Value' --output text

  2. Connect to database:
     export DATABASE_URL="${module.timescaledb.database_connection_string}"
     psql $DATABASE_URL

  3. SSH to instance:
     ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${module.timescaledb.instance_public_ip}

  4. View Docker logs:
     ssh ubuntu@${module.timescaledb.instance_public_ip} "docker logs -f timescaledb"

  5. Run migrations:
     cd lighthouse/backend
     export DATABASE_URL="${module.timescaledb.database_connection_string}"
     sqlx migrate run

  Estimated cost: ${module.timescaledb.estimated_monthly_cost_usd}/month

  EOT
}
