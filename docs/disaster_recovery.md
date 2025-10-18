Disaster Recovery Plan

Objectives
- RTO: 4 hours for warehouse read workloads; 8 hours for full pipeline.
- RPO: 15 minutes for Redshift (automated snapshots), near-zero for S3 (CRR).

Scope
- Redshift RA3 cluster, S3 raw/stage/curated buckets, Lambda functions, IAM, EventBridge, dashboards, Matillion jobs.

Data Protection
- Redshift
  - Automated snapshots enabled; retain 7–14 days.
  - Manual snapshots pre/post major changes; tag with release identifiers.
  - Cross-region snapshot copy to DR region; encrypt with KMS key in DR.
- S3
  - Cross-Region Replication (CRR) from raw/stage/curated to DR buckets (same KMS policy).
  - Lifecycle policies to optimize storage; CRR destination has longer retention.
- Secrets
  - Secrets Manager replication enabled for critical secrets (Redshift, Matillion).

Infra-as-Code Recovery
1) Provision DR VPC and dependencies
   - Terraform apply with `-var-file=terraform.dr.tfvars` (DR region, bucket suffix, KMS alias).
2) Restore data
   - Promote latest Redshift snapshot in DR; update DNS/connection strings.
   - S3 data already replicated; validate prefixes and manifests.
3) Rehydrate apps
   - Deploy Lambdas and EventBridge rules; validate permissions.
   - Reconnect Matillion to DR Redshift endpoint and secrets.

Failover Procedure
1) Declare incident; freeze non-essential changes; notify stakeholders.
2) Identify latest healthy Redshift snapshot; restore in DR.
3) Update connection endpoints for BI/ETL (param store or DNS alias).
4) Validate health checks and DQ gates; open access gradually.
5) Post-incident: root cause, backfill deltas back to primary, plan failback.

Testing & Game Days
- Quarterly DR drill: full restore to DR, run smoke ETL and BI queries, measure RTO/RPO.
- Capture metrics into `${project}/DR` CloudWatch namespace.

Runbooks & Contacts
- On-call rotations in PagerDuty; EventBridge forwards CW Alarms.
- Escalation: Data Engineering → Platform → Security.

