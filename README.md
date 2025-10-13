# Bank Deposits Mart — Production-Ready (Final)

A complete, bank-grade implementation of a **Redshift-based data warehouse** with **S3 landing**, **Lambda guardrails**, **Matillion ETL**, **RLS + masking**, **Power BI secure views**, **DQ gates**, **observability**, and **CI/CD**.

## What’s inside
- `infra/terraform/` — Production IaC for AWS (VPC-private, KMS, S3, Redshift RA3, IAM, SNS, SQS DLQ, EventBridge, optional NAT).
- `sql/` — Redshift DDL (stage/core/mart), ETL SQL, manifest/incremental patterns, security (RLS + masking), and admin helpers.
- `matillion/` — Orchestration/transformation jobs (JSON templates) and environment variables.
- `lambda/` — Schema validator, DQ success notifier; production patterns (DLQ, Secrets).
- `dq/` — Data Quality runner (Python) with examples.
- `monitoring/` — CloudWatch alarms and dashboards; EventBridge routing to PagerDuty/ServiceNow.
- `powerbi/` — Modeling & security notes; DAX measures; connection guidance.
- `docs/` — Architecture, warehouse overview, lineage, runbook, and SOPs.
- `tests/` — SQL acceptance tests and Lambda unit tests.
- `sample_data/` — CSV/JSON to smoke-test end-to-end.

> **Placeholders to replace**: `<YOUR_AWS_ACCOUNT_ID>`, `<unique>` bucket suffix, admin usernames, and PagerDuty token/API roles.
