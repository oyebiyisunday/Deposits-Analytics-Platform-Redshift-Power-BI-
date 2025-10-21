variable "region" { type=string default="us-east-1" }
variable "project" { type=string default="deposits-analytics-platform" }
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

# Glue/Lake Formation for curated Parquet
variable "glue_db_name" {
  type        = string
  default     = "curated_db"
  description = "AWS Glue database name for curated datasets."
}

variable "enable_lake_formation" {
  type        = bool
  default     = false
  description = "Enable Lake Formation and grants for curated data."
}

variable "lake_formation_admins" {
  type        = list(string)
  default     = []
  description = "Lake Formation admin principals (IAM ARNs)."
}

# SageMaker
variable "enable_sagemaker_notebook" {
  type        = bool
  default     = false
  description = "Provision a SageMaker notebook instance in the VPC."
}

variable "sagemaker_instance_type" {
  type        = string
  default     = "ml.t3.medium"
  description = "Instance type for SageMaker notebook."
}

variable "enable_feature_store" {
  type        = bool
  default     = false
  description = "Provision an example SageMaker Feature Store group."
}

# PgBouncer (connection pooling)
variable "enable_pgbouncer" {
  type        = bool
  default     = false
  description = "Deploy PgBouncer on ECS Fargate for Redshift pooling."
}
variable "pgbouncer_desired_count" { type = number, default = 1 }
variable "pgbouncer_allowed_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDRs allowed to connect to PgBouncer NLB (clients/BI)."
}
variable "pgbouncer_max_client_conn" { type = number, default = 200 }

# S3 Cross-Region Replication (CRR)
variable "enable_crr" {
  type        = bool
  default     = false
  description = "Enable S3 bucket replication to DR region."
}
variable "crr_retention_days" { type = number, default = 365 }

# Cost controls
variable "enable_budgets" {
  type        = bool
  default     = false
  description = "Create an AWS Budget for monthly costs with email alerts."
}

variable "budget_amount" {
  type        = number
  default     = 500
  description = "Monthly budget amount in USD."
}

variable "budget_emails" {
  type        = list(string)
  default     = []
  description = "Email addresses to notify for budget and anomaly alerts."
}

variable "enable_cost_anomaly_detection" {
  type        = bool
  default     = false
  description = "Enable Cost Explorer anomaly monitor and subscription."
}

# Redshift ops
variable "redshift_maintenance_cron" {
  type        = string
  default     = "cron(30 2 * * ? *)" # 02:30 UTC daily
  description = "EventBridge schedule for Redshift VACUUM/ANALYZE maintenance."
}

variable "redshift_database" {
  type        = string
  default     = "dev"
  description = "Default Redshift database name for maintenance jobs."
}

# Redshift tuning
variable "enable_redshift_sqa" {
  type        = bool
  default     = true
  description = "Enable Short Query Acceleration in Redshift parameter group."
}

variable "max_concurrency_scaling_clusters" {
  type        = number
  default     = 1
  description = "Max concurrency scaling clusters for Redshift."
}

# Redshift automated snapshot retention (days)
variable "redshift_automated_snapshot_retention" {
  type        = number
  default     = 7
  description = "Automated snapshot retention period for Redshift (days)."
}
