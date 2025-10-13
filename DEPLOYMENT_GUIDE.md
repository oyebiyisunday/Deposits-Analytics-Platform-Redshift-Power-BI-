# Production Deployment Guide for ETL Pipeline

## 🚀 Production-Ready ETL Pipeline Deployment

This guide covers deploying the enhanced ETL pipeline with:
- ⏰ **Automatic Scheduling** (daily at 00:15 UTC)
- 🔄 **Retry Logic** (exponential backoff + DLQ)
- 📊 **SLA Monitoring** (arrival, processing, freshness)
- 🔧 **Enhanced Error Handling**
- 📈 **Comprehensive Monitoring**

## Prerequisites

- AWS CLI configured
- Terraform >= 1.6.0
- Matillion ETL instance
- Appropriate AWS permissions

## Quick Deployment

### 1. Configure Variables
```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
region              = "us-east-1"
redshift_username   = "your-username"
redshift_password   = "your-password"
matillion_base_url  = "https://your-matillion.com"
matillion_user      = "matillion-user"
matillion_password  = "matillion-password"
```

### 2. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 3. Configure Secrets
```bash
# Store Matillion credentials
aws secretsmanager create-secret \
  --name "bank-deposits-mart-final/matillion" \
  --secret-string '{"username":"user","password":"pass"}'

# Store Redshift credentials  
aws secretsmanager create-secret \
  --name "bank-deposits-mart-final/redshift" \
  --secret-string '{"host":"endpoint","username":"user","password":"pass"}'
```

### 4. Import Dashboards
```bash
# Import monitoring dashboards
aws cloudwatch put-dashboard \
  --dashboard-name "ETL-Pipeline-Health" \
  --dashboard-body file://monitoring/dashboards/sla_pipeline_health.json
```

## Features Deployed

✅ **Scheduling**: Daily ETL at 00:15 UTC  
✅ **Retry Logic**: 3 attempts with exponential backoff  
✅ **SLA Monitoring**: 30/60/120 minute thresholds  
✅ **Error Handling**: DLQ and circuit breakers  
✅ **Monitoring**: Real-time dashboards  
✅ **Cost Control**: Lifecycle policies and optimization  

## Validation

### Test Scheduling
```bash
aws lambda invoke \
  --function-name bank-deposits-mart-final-matillion-trigger \
  --payload '{"job_name":"J_ORCH_Load_Deposits","manual_trigger":true}' \
  response.json
```

### Check SLA Compliance
- View dashboards in CloudWatch
- Monitor SNS alerts
- Review DynamoDB SLA tracking table

## Operational Procedures

### Daily Monitoring
1. Check pipeline health dashboard
2. Review SLA compliance metrics  
3. Investigate any DLQ messages
4. Validate cost metrics

### Incident Response
1. **Job Failures**: Check retry handler and DLQ
2. **SLA Breaches**: Use dashboards for root cause analysis
3. **Performance Issues**: Review Redshift metrics
4. **Cost Spikes**: Check resource utilization

## Support

- **Logs**: CloudWatch `/aws/lambda/` groups
- **Metrics**: Custom namespace `bank-deposits-mart-final/`
- **Alerts**: SNS topic for notifications
- **Dashboards**: CloudWatch for real-time monitoring

Ready for production! 🎉