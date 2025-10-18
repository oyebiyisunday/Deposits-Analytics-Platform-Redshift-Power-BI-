variable "region" { type=string default="us-east-1" }
variable "project" { type=string default="bank-deposits-mart-final" }
variable "bucket_suffix" { type=string description="Unique suffix for S3 bucket names (DNS-safe)." }
variable "vpc_cidr" { type=string default="10.42.0.0/16" }
variable "private_subnets" { type=list(string) default=["10.42.1.0/24","10.42.2.0/24"] }
variable "public_subnets"  { type=list(string) default=["10.42.11.0/24","10.42.12.0/24"] }
variable "redshift_username" { type=string }
variable "redshift_password" { type=string sensitive=true }

# Optional: attach specific security groups to Redshift cluster
variable "redshift_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of VPC security group IDs to attach to Redshift cluster."
}

# Networking controls
variable "nat_enabled" {
  type        = bool
  default     = true
  description = "Create NAT gateway and route private subnets for egress."
}

variable "public_subnet_nat_index" {
  type        = number
  default     = 0
  description = "Index of public subnet to host the NAT gateway."
}

variable "allowed_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDR blocks allowed to access Redshift (e.g., office IPs)."
}

variable "enable_vpc_endpoints" {
  type        = bool
  default     = true
  description = "Create VPC endpoints for S3 (gateway) and Secrets Manager/CloudWatch Logs (interface)."
}

# Matillion Integration Variables
variable "matillion_base_url" { 
  type=string 
  description="Base URL for Matillion ETL instance"
}
variable "matillion_user" { 
  type=string 
  description="Matillion ETL username"
}
variable "matillion_password" { 
  type=string 
  sensitive=true
  description="Matillion ETL password"
}

# Optional: Webhook for DQ success notifications
variable "dq_webhook_url" {
  type        = string
  default     = null
  description = "Optional webhook URL for DQ success notifications (Slack/Teams/etc)."
}

# Optional: PagerDuty integration via EventBridge API destination
variable "enable_pagerduty" {
  type        = bool
  default     = false
  description = "Enable PagerDuty forwarding of CloudWatch alarms."
}

variable "pagerduty_token" {
  type        = string
  default     = null
  description = "PagerDuty API token when enable_pagerduty = true."
}

variable "eventbridge_invoke_role_arn" {
  type        = string
  default     = null
  description = "IAM role ARN allowing EventBridge to call API destinations."
}
