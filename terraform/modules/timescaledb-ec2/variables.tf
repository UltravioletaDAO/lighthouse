# ============================================================================
# TimescaleDB EC2 Module - Variables
# ============================================================================

# ============================================================================
# General Configuration
# ============================================================================

variable "name_prefix" {
  description = "Prefix for all resource names (e.g., 'lighthouse-prod')"
  type        = string
  default     = "lighthouse"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Lighthouse"
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}

# ============================================================================
# Network Configuration
# ============================================================================

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for EBS volume (must match subnet AZ). Leave empty to auto-detect."
  type        = string
  default     = ""
}

variable "associate_public_ip" {
  description = "Associate public IP with instance (set to false for private subnet)"
  type        = bool
  default     = false
}

# ============================================================================
# Security Configuration
# ============================================================================

variable "allowed_security_groups" {
  description = "Security groups allowed to connect to PostgreSQL port (e.g., backend security group)"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to PostgreSQL port"
  type        = list(string)
  default     = []
}

variable "enable_ssh_access" {
  description = "Enable SSH access for maintenance"
  type        = bool
  default     = true
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Restrict this in production
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = ""
}

# ============================================================================
# Instance Configuration
# ============================================================================

variable "instance_type" {
  description = "EC2 instance type (t4g.micro for MVP, t4g.small for growth, t4g.medium for scale)"
  type        = string
  default     = "t4g.micro"

  validation {
    condition     = can(regex("^t4g\\.(micro|small|medium|large)$", var.instance_type))
    error_message = "Instance type must be a Graviton2 instance (t4g.micro, t4g.small, t4g.medium, t4g.large)"
  }
}

variable "use_spot_instance" {
  description = "Use spot instance for 70-90% cost savings (acceptable for dev/staging)"
  type        = bool
  default     = false
}

# ============================================================================
# Storage Configuration
# ============================================================================

variable "volume_size_gb" {
  description = "EBS volume size in GB (20 for Year 1, 100 for Year 2, 500 for Year 3)"
  type        = number
  default     = 20

  validation {
    condition     = var.volume_size_gb >= 20 && var.volume_size_gb <= 16384
    error_message = "Volume size must be between 20 GB and 16 TB"
  }
}

variable "volume_type" {
  description = "EBS volume type (gp3 recommended for cost-performance balance)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp3", "gp2", "io1", "io2"], var.volume_type)
    error_message = "Volume type must be one of: gp3, gp2, io1, io2"
  }
}

variable "volume_iops" {
  description = "Provisioned IOPS for gp3 volume (3000-16000, default 3000 is free)"
  type        = number
  default     = 3000

  validation {
    condition     = var.volume_iops >= 3000 && var.volume_iops <= 16000
    error_message = "IOPS must be between 3000 and 16000"
  }
}

variable "volume_throughput" {
  description = "Throughput in MB/s for gp3 volume (125-1000, default 125 is free)"
  type        = number
  default     = 125

  validation {
    condition     = var.volume_throughput >= 125 && var.volume_throughput <= 1000
    error_message = "Throughput must be between 125 and 1000 MB/s"
  }
}

variable "volume_encrypted" {
  description = "Encrypt EBS volume at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for EBS encryption (leave empty to use default aws/ebs key)"
  type        = string
  default     = ""
}

# ============================================================================
# Database Configuration
# ============================================================================

variable "postgres_password" {
  description = "PostgreSQL password (use AWS Secrets Manager in production)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.postgres_password) >= 16
    error_message = "Password must be at least 16 characters long"
  }
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "lighthouse"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]{0,62}$", var.database_name))
    error_message = "Database name must start with a letter, contain only lowercase letters, numbers, and underscores"
  }
}

variable "postgres_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"

  validation {
    condition     = contains(["14", "15", "16"], var.postgres_version)
    error_message = "PostgreSQL version must be 14, 15, or 16"
  }
}

variable "timescaledb_image" {
  description = "TimescaleDB Docker image"
  type        = string
  default     = "timescale/timescaledb:latest-pg16"
}

# ============================================================================
# Backup Configuration
# ============================================================================

variable "enable_automated_backups" {
  description = "Enable automated EBS snapshots via AWS Backup"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Cron expression for backup schedule (default: 2 AM UTC daily)"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 365
    error_message = "Backup retention must be between 7 and 365 days"
  }
}

variable "backup_cross_region_copy" {
  description = "Copy backups to another region for disaster recovery"
  type        = bool
  default     = false
}

variable "backup_s3_bucket" {
  description = "S3 bucket for logical backups (pg_dump)"
  type        = string
  default     = ""
}

# ============================================================================
# Monitoring Configuration
# ============================================================================

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = true
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm (percentage)"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alarm_threshold > 0 && var.cpu_alarm_threshold <= 100
    error_message = "CPU alarm threshold must be between 1 and 100"
  }
}

variable "disk_alarm_threshold" {
  description = "Disk usage threshold for CloudWatch alarm (percentage)"
  type        = number
  default     = 85

  validation {
    condition     = var.disk_alarm_threshold > 0 && var.disk_alarm_threshold <= 100
    error_message = "Disk alarm threshold must be between 1 and 100"
  }
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

# ============================================================================
# DNS Configuration (Optional)
# ============================================================================

variable "create_dns_record" {
  description = "Create Route53 DNS record for database endpoint"
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID (required if create_dns_record is true)"
  type        = string
  default     = ""
}

variable "dns_name" {
  description = "DNS name for database endpoint (e.g., 'db.lighthouse.example.com')"
  type        = string
  default     = ""
}
