# ============================================================================
# Development Environment Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "ssh_key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = "lighthouse-dev"

  validation {
    condition     = length(var.ssh_key_name) > 0
    error_message = "SSH key name is required for dev environment"
  }
}
