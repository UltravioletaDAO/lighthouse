# ============================================================================
# TimescaleDB EC2 Module - Outputs
# ============================================================================

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.timescaledb.id
}

output "instance_public_ip" {
  description = "Public IP address (if associate_public_ip is true)"
  value       = aws_instance.timescaledb.public_ip
}

output "instance_private_ip" {
  description = "Private IP address"
  value       = aws_instance.timescaledb.private_ip
}

output "database_endpoint" {
  description = "Database connection endpoint (private IP or DNS name)"
  value       = var.create_dns_record ? var.dns_name : aws_instance.timescaledb.private_ip
}

output "database_connection_string" {
  description = "PostgreSQL connection string (use in backend configuration)"
  value       = "postgresql://postgres:${var.postgres_password}@${var.create_dns_record ? var.dns_name : aws_instance.timescaledb.private_ip}:5432/${var.database_name}"
  sensitive   = true
}

output "volume_id" {
  description = "EBS volume ID (persistent storage)"
  value       = aws_ebs_volume.timescaledb_data.id
}

output "volume_arn" {
  description = "EBS volume ARN (for backup policies)"
  value       = aws_ebs_volume.timescaledb_data.arn
}

output "security_group_id" {
  description = "Security group ID (use for backend ingress rules)"
  value       = aws_security_group.timescaledb.id
}

output "backup_vault_arn" {
  description = "AWS Backup vault ARN (empty if backups disabled)"
  value       = var.enable_automated_backups ? aws_backup_vault.timescaledb[0].arn : ""
}

output "instance_profile_arn" {
  description = "IAM instance profile ARN"
  value       = aws_iam_instance_profile.timescaledb.arn
}

# ============================================================================
# CloudWatch Alarm ARNs
# ============================================================================

output "cpu_alarm_arn" {
  description = "CPU utilization alarm ARN (empty if monitoring disabled)"
  value       = var.enable_monitoring ? aws_cloudwatch_metric_alarm.cpu_high[0].arn : ""
}

output "disk_alarm_arn" {
  description = "Disk usage alarm ARN (empty if monitoring disabled)"
  value       = var.enable_monitoring ? aws_cloudwatch_metric_alarm.disk_high[0].arn : ""
}

output "instance_status_alarm_arn" {
  description = "Instance status check alarm ARN (empty if monitoring disabled)"
  value       = var.enable_monitoring ? aws_cloudwatch_metric_alarm.instance_status[0].arn : ""
}

# ============================================================================
# DNS Information
# ============================================================================

output "dns_name" {
  description = "Route53 DNS name (empty if create_dns_record is false)"
  value       = var.create_dns_record ? aws_route53_record.timescaledb[0].fqdn : ""
}

# ============================================================================
# Cost Estimation
# ============================================================================

output "estimated_monthly_cost_usd" {
  description = "Estimated monthly cost in USD (rough approximation)"
  value = format("$%.2f", (
    # EC2 instance cost (based on instance type, on-demand pricing)
    lookup({
      "t4g.micro"  = 0.0084 * 730,  # $6.13/month
      "t4g.small"  = 0.0168 * 730,  # $12.26/month
      "t4g.medium" = 0.0336 * 730,  # $24.53/month
      "t4g.large"  = 0.0672 * 730,  # $49.06/month
    }, var.instance_type, 0.0084 * 730) * (var.use_spot_instance ? 0.3 : 1.0) + # 70% discount for spot

    # EBS volume cost ($0.08/GB/month for gp3)
    (var.volume_size_gb * 0.08) +

    # Snapshot cost (estimated 10% of volume size, $0.05/GB/month)
    (var.enable_automated_backups ? var.volume_size_gb * 0.1 * 0.05 : 0)
  ))
}

# ============================================================================
# Connection Instructions
# ============================================================================

output "connection_instructions" {
  description = "Instructions for connecting to the database"
  value       = <<-EOT

  TimescaleDB Connection Information:

  Endpoint:  ${var.create_dns_record ? var.dns_name : aws_instance.timescaledb.private_ip}
  Port:      5432
  Database:  ${var.database_name}
  User:      postgres

  Connection string:
  export DATABASE_URL="postgresql://postgres:REDACTED@${var.create_dns_record ? var.dns_name : aws_instance.timescaledb.private_ip}:5432/${var.database_name}"

  Test connection:
  psql -h ${var.create_dns_record ? var.dns_name : aws_instance.timescaledb.private_ip} -U postgres -d ${var.database_name}

  SSH access (if enabled):
  ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${var.associate_public_ip ? aws_instance.timescaledb.public_ip : aws_instance.timescaledb.private_ip}

  View Docker logs:
  ssh ubuntu@${var.associate_public_ip ? aws_instance.timescaledb.public_ip : aws_instance.timescaledb.private_ip} "docker logs timescaledb"

  EOT
}
