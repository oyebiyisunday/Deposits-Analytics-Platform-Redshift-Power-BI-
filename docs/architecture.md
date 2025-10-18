# Architecture
S3 (raw) → Lambda guard → Matillion → Redshift (stage/core/mart) → Secure Views (RLS+masking) → Power BI.
Observability via CloudWatch + SNS + EventBridge (PagerDuty/ServiceNow). IaC via Terraform. DQ gates block BI refresh.
