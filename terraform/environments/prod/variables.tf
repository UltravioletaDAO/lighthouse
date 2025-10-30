# ============================================================================
# Production Environment Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# ============================================================================
# Network Configuration
# ============================================================================

variable "vpc_name" {
  description = "Name of existing VPC"
  type        = string
  default     = "lighthouse-prod-vpc"
}

variable "private_subnet_name" {
  description = "Name of private subnet for database"
  type        = string
  default     = "lighthouse-prod-private-subnet"
}

variable "backend_security_group_name" {
  description = "Name of backend security group (allowed to access database)"
  type        = string
  default     = "lighthouse-prod-backend-sg"
}

# ============================================================================
# Database Configuration
# ============================================================================

variable "instance_type" {
  description = "EC2 instance type (t4g.small for Year 1-2, t4g.medium for Year 3)"
  type        = string
  default     = "t4g.small"

  validation {
    condition     = contains(["t4g.micro", "t4g.small", "t4g.medium", "t4g.large"], var.instance_type)
    error_message = "Instance type must be a Graviton2 instance (t4g.micro, t4g.small, t4g.medium, t4g.large)"
  }
}

variable "volume_size_gb" {
  description = "EBS volume size in GB (100 for Year 1-2, 500 for Year 3)"
  type        = number
  default     = 100

  validation {
    condition     = var.volume_size_gb >= 20 && var.volume_size_gb <= 16384
    error_message = "Volume size must be between 20 GB and 16 TB"
  }
}

variable "db_password_secret_id" {
  description = "AWS Secrets Manager secret ID containing database password"
  type        = string
  default     = "lighthouse/prod/db/password"
}

# ============================================================================
# Backup Configuration
# ============================================================================

variable "backup_s3_bucket" {
  description = "S3 bucket for logical backups (pg_dump)"
  type        = string
  default     = "lighthouse-backups-prod"
}

# ============================================================================
# Monitoring Configuration
# ============================================================================

variable "alerts_sns_topic_name" {
  description = "SNS topic name for CloudWatch alarms"
  type        = string
  default     = "lighthouse-prod-alerts"
}

# ============================================================================
# DNS Configuration
# ============================================================================

variable "domain_name" {
  description = "Domain name for Route53 (e.g., karmacadabra.ultravioletadao.xyz)"
  type        = string
  default     = "karmacadabra.ultravioletadao.xyz"
}

# ============================================================================
# SSH Access
# ============================================================================

variable "ssh_key_name" {
  description = "EC2 key pair name for emergency SSH access"
  type        = string
  default     = "lighthouse-prod"
}

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks allowed for SSH (bastion host or VPN only)"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Internal VPC only

  validation {
    condition     = !contains(var.ssh_allowed_cidr_blocks, "0.0.0.0/0")
    error_message = "SSH access from 0.0.0.0/0 is not allowed in production. Use bastion host or VPN."
  }
}
