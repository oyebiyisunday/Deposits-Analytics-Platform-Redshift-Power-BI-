# Production Deployment Guide for ETL Pipeline

## Production-Ready ETL Pipeline Deployment

This guide covers deploying the enhanced ETL pipeline with:
- Automatic Scheduling (daily at 00:15 UTC)
- Retry Logic (exponential backoff + DLQ)
- SLA Monitoring (arrival, processing, freshness)
- Enhanced Error Handling
- Comprehensive Monitoring

## Prerequisites

- AWS CLI configured
- Terraform >= 1.6.0
- Matillion ETL instance
- Appropriate AWS permissions

## Quick Deployment

### 1. Configure Variables
```
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
region              = "us-east-1"
bucket_suffix       = "your-unique-suffix"   # used in S3 bucket names
redshift_username   = "your-username"
redshift_password   = "your-password"
matillion_base_url  = "https://your-matillion.com"
matillion_user      = "matillion-user"
matillion_password  = "matillion-password"
```

### 2. Deploy Infrastructure
Terraform now bundles Lambda code automatically; no manual zips are required.
```
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 3. Configure Secrets
```
# Store Matillion credentials
aws secretsmanager create-secret \
  --name "bank-deposits-mart-final/matillion" \
  --secret-string '{"username":"user","password":"pass"}'

# Store Redshift credentials
aws secretsmanager create-secret \
  --name "bank-deposits-mart-final/redshift" \
  --secret-string '{"host":"endpoint","username":"user","password":"pass"}'
```

### 4. Dashboards
CloudWatch dashboards are provisioned by Terraform (`aws_cloudwatch_dashboard`).

## Features Deployed

- Scheduling: Daily ETL at 00:15 UTC
- Retry Logic: 3 attempts with exponential backoff
- SLA Monitoring: 30/60/120 minute thresholds
- Error Handling: DLQ and circuit breakers
- Monitoring: Real-time dashboards
- S3 Schema Validation: Auto-validates raw file headers; alerts on mismatch
- Cost Control: Lifecycle policies and optimization

## Validation

### Test Scheduling
```
aws lambda invoke \
  --function-name bank-deposits-mart-final-matillion-trigger \
  --payload '{"job_name":"J_ORCH_Load_Deposits","manual_trigger":true}' \
  response.json
```

### Check SLA Compliance
- View dashboards in CloudWatch
- Monitor SNS alerts
- Review DynamoDB SLA tracking table (if enabled)

## Configuration Notes

- Set `bucket_suffix`, `matillion_*`, and Redshift credentials in `terraform.tfvars`.
- To enable PagerDuty forwarding, set `enable_pagerduty=true`, `pagerduty_token`, and `eventbridge_invoke_role_arn`.
- Optional DQ success webhook: set `dq_webhook_url`.
- Networking: NAT is enabled by default. Set `allowed_cidrs` to your office/VPN CIDRs for Redshift SG.
 - VPC Endpoints: Enabled by default for S3 (gateway) and Secrets Manager/CloudWatch Logs (interface). Toggle with `enable_vpc_endpoints`.

## Security Hardening

- Lambda SNS publish permissions scoped to the project alerts topic.
- S3 buckets are KMS-encrypted and block public access.

## SQL Template Rendering

Use the renderer to produce environment-specific COPY scripts:
```
python scripts/render_sql.py \
  --project bank-deposits-mart-final \
  --bucket-suffix <your-suffix> \
  --aws-account-id <acct-id> \
  --redshift-role-name <RedshiftS3ReadRole>
```
Outputs in `dist/sql/`.

## Data Quality Metrics

- Lambda: `${project}-dq-metrics` accepts DQ results and publishes metrics to CloudWatch under `${project}/DQ`.
- CI: `.github/workflows/dq.yml` runs `dq/runner.py` and publishes metrics. Provide Redshift connection secrets and an AWS role.

## Operational Procedures

### Daily Monitoring
1. Check pipeline health dashboard
2. Review SLA compliance metrics
3. Investigate any DLQ messages
4. Validate cost metrics

### Incident Response
1. Job Failures: Check retry handler and DLQ
2. SLA Breaches: Use dashboards for root cause analysis
3. Performance Issues: Review Redshift metrics
4. Cost Spikes: Check resource utilization

## Support

- Logs: CloudWatch `/aws/lambda/` groups
- Metrics: Custom namespace `bank-deposits-mart-final/`
- Alerts: SNS topic for notifications
- Dashboards: CloudWatch for real-time monitoring

Ready for production!
