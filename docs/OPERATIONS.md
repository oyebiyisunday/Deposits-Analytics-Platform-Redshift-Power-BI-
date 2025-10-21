# Operations — Deposits Analytics Platform

This guide summarizes day‑to‑day operations.

## Daily
- Check CloudWatch dashboard `${project}-ETL-Pipeline-Health`.
- Review CloudWatch alarms (DQ, SLA, Lambda errors, Redshift CPU/WLM); triage alerts from SNS topic `${project}-alerts`.
- Inspect DLQs (`${project}-lambda-dlq`, `${project}-matillion-failure-dlq`) if present.

## Data Quality
- Automated: `lambda/dq_metrics_publisher` writes `DQFailures`, `DQCheck` metrics.
- Ad‑hoc: run `python dq/runner.py` with RS env vars to validate.

## Maintenance
- Redshift maintenance Lambda runs VACUUM/ANALYZE on schedule defined in Terraform.
- Monitor performance widgets: QueryDuration, WLMQueueLength, CPUUtilization.

## Cost Controls
- Optional budgets and anomaly detection are toggleable in Terraform; ensure `budget_emails` is set.

## Incident Response
- Schema validation failure: see Lambda logs `/aws/lambda/${project}-validate-schema` and SNS alerts.
- ETL job failures: check retry DLQs and Matillion job logs; re‑run via trigger Lambda.
- Redshift saturation: evaluate WLM queue, scale nodes, or optimize queries.

## Access & Secrets
- Redshift creds live in Secrets Manager `${var.project}/redshift`; enable rotation.
- For PgBouncer (optional), ensure ECS task reads `username` and `password` keys from the secret.

## Runbooks
- See `docs/runbook.md` and `docs/disaster_recovery.md` for deep procedures.

