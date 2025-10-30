# ============================================================================
# TimescaleDB on EC2 + EBS - Self-Managed Deployment
# ============================================================================
# This module deploys PostgreSQL + TimescaleDB on EC2 with persistent EBS storage
#
# Cost (Year 1): ~$8-10/month (t4g.micro + 20GB gp3)
# Uptime: 99% (5-10 min monthly downtime acceptable)
# Use case: MVP (50-500 subscriptions)
# ============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ============================================================================
# Data Sources
# ============================================================================

# Latest Ubuntu 22.04 LTS AMI (ARM64 for Graviton2)
data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hbn-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# Get current AWS region
data "aws_region" "current" {}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================================
# Security Group
# ============================================================================

resource "aws_security_group" "timescaledb" {
  name_prefix = "${var.name_prefix}-timescaledb-"
  description = "Security group for TimescaleDB EC2 instance"
  vpc_id      = var.vpc_id

  # PostgreSQL port (restricted to backend security group)
  ingress {
    description     = "PostgreSQL from backend"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    cidr_blocks     = var.allowed_cidr_blocks
  }

  # SSH access (optional, for maintenance)
  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  }

  # Outbound internet access (for package updates)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-timescaledb-sg"
    }
  )
}

# ============================================================================
# EBS Volume (Persistent Storage)
# ============================================================================

resource "aws_ebs_volume" "timescaledb_data" {
  availability_zone = var.availability_zone != "" ? var.availability_zone : data.aws_availability_zones.available.names[0]
  size              = var.volume_size_gb
  type              = var.volume_type
  iops              = var.volume_type == "gp3" ? var.volume_iops : null
  throughput        = var.volume_type == "gp3" ? var.volume_throughput : null
  encrypted         = var.volume_encrypted
  kms_key_id        = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name   = "${var.name_prefix}-timescaledb-data"
      Backup = "daily" # Used by AWS Backup
    }
  )
}

# ============================================================================
# EC2 Instance
# ============================================================================

resource "aws_instance" "timescaledb" {
  ami           = data.aws_ami.ubuntu_arm64.id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Network configuration
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.timescaledb.id]
  associate_public_ip_address = var.associate_public_ip

  # Use spot instance if enabled (70-90% discount)
  instance_market_options {
    market_type = var.use_spot_instance ? "spot" : null

    dynamic "spot_options" {
      for_each = var.use_spot_instance ? [1] : []
      content {
        spot_instance_type             = "persistent"
        instance_interruption_behavior = "stop" # Stop instance but keep EBS volume
      }
    }
  }

  # IAM role for CloudWatch, SSM, and AWS Backup
  iam_instance_profile = aws_iam_instance_profile.timescaledb.name

  # User data script (bootstrap TimescaleDB)
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    volume_device_name = "/dev/sdf"
    mount_point        = "/mnt/timescaledb-data"
    postgres_password  = var.postgres_password
    database_name      = var.database_name
    postgres_version   = var.postgres_version
    timescaledb_image  = var.timescaledb_image
    enable_monitoring  = var.enable_monitoring
  }))

  # Root volume (OS, Docker images)
  root_block_device {
    volume_size           = 20 # GB
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # Ensure instance doesn't start until EBS volume is created
  depends_on = [aws_ebs_volume.timescaledb_data]

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-timescaledb"
    }
  )
}

# ============================================================================
# EBS Volume Attachment
# ============================================================================

resource "aws_volume_attachment" "timescaledb_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.timescaledb_data.id
  instance_id = aws_instance.timescaledb.id

  # Don't force detach on destroy (safety measure)
  force_detach = false

  # Wait for instance to be fully running
  depends_on = [aws_instance.timescaledb]
}

# ============================================================================
# IAM Role for EC2 Instance
# ============================================================================

resource "aws_iam_role" "timescaledb" {
  name_prefix = "${var.name_prefix}-timescaledb-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.timescaledb.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.timescaledb.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom policy for EBS snapshots and backup tagging
resource "aws_iam_role_policy" "timescaledb_backup" {
  name_prefix = "${var.name_prefix}-backup-"
  role        = aws_iam_role.timescaledb.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.backup_s3_bucket}/*"
        Condition = {
          StringLike = {
            "s3:prefix" = ["backups/timescaledb/*"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "timescaledb" {
  name_prefix = "${var.name_prefix}-timescaledb-"
  role        = aws_iam_role.timescaledb.name

  tags = var.tags
}

# ============================================================================
# AWS Backup Plan (Automated Snapshots)
# ============================================================================

resource "aws_backup_vault" "timescaledb" {
  count = var.enable_automated_backups ? 1 : 0
  name  = "${var.name_prefix}-timescaledb-vault"

  tags = var.tags
}

resource "aws_backup_plan" "timescaledb" {
  count = var.enable_automated_backups ? 1 : 0
  name  = "${var.name_prefix}-timescaledb-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.timescaledb[0].name
    schedule          = var.backup_schedule # Default: "cron(0 2 * * ? *)" = 2 AM UTC daily

    lifecycle {
      delete_after = var.backup_retention_days
    }

    # Copy to another region for disaster recovery
    dynamic "copy_action" {
      for_each = var.backup_cross_region_copy ? [1] : []
      content {
        destination_vault_arn = aws_backup_vault.timescaledb_dr[0].arn

        lifecycle {
          delete_after = var.backup_retention_days
        }
      }
    }
  }

  tags = var.tags
}

# Cross-region backup vault (optional)
resource "aws_backup_vault" "timescaledb_dr" {
  count    = var.backup_cross_region_copy ? 1 : 0
  name     = "${var.name_prefix}-timescaledb-vault-dr"
  provider = aws.dr_region # Requires provider alias

  tags = var.tags
}

# Backup selection (which resources to backup)
resource "aws_backup_selection" "timescaledb" {
  count        = var.enable_automated_backups ? 1 : 0
  name         = "${var.name_prefix}-timescaledb-selection"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.timescaledb[0].id

  resources = [
    aws_ebs_volume.timescaledb_data.arn
  ]
}

# IAM role for AWS Backup
resource "aws_iam_role" "backup" {
  name_prefix = "${var.name_prefix}-backup-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# ============================================================================
# CloudWatch Alarms
# ============================================================================

# CPU utilization alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.name_prefix}-timescaledb-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "Triggered when CPU utilization exceeds ${var.cpu_alarm_threshold}%"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    InstanceId = aws_instance.timescaledb.id
  }

  tags = var.tags
}

# Disk space alarm (requires CloudWatch agent on instance)
resource "aws_cloudwatch_metric_alarm" "disk_high" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.name_prefix}-timescaledb-disk-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = var.disk_alarm_threshold
  alarm_description   = "Triggered when disk usage exceeds ${var.disk_alarm_threshold}%"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    InstanceId = aws_instance.timescaledb.id
    path       = "/mnt/timescaledb-data"
    device     = "nvme1n1"
  }

  tags = var.tags
}

# Instance status check alarm
resource "aws_cloudwatch_metric_alarm" "instance_status" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.name_prefix}-timescaledb-instance-status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Triggered when instance status check fails"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    InstanceId = aws_instance.timescaledb.id
  }

  tags = var.tags
}

# ============================================================================
# Route53 DNS Record (Optional)
# ============================================================================

resource "aws_route53_record" "timescaledb" {
  count   = var.create_dns_record ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.dns_name
  type    = "A"
  ttl     = 300
  records = [var.associate_public_ip ? aws_instance.timescaledb.public_ip : aws_instance.timescaledb.private_ip]
}
