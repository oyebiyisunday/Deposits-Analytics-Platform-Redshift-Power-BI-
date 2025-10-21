# Deposits Analytics Platform (Redshift + Power BI)

A complete, bank-grade implementation of a Redshift-based data warehouse with S3 landing, Lambda guardrails, Matillion ETL, row-level security (RLS) + masking via secure views, Power BI secure views, DQ gates, observability, and CI/CD.

## What's inside
- `infra/terraform/` — Production IaC for AWS (VPC-private, KMS, S3, Redshift RA3, IAM, SNS, SQS DLQ, EventBridge, optional NAT, dashboards).
- `sql/` — Redshift DDL (stage/core/mart), ETL SQL, manifest/incremental patterns, security (RLS + masking), and admin helpers.
- `matillion/` — Orchestration/transformation jobs (JSON templates) and environment variables.
- `lambda/` — Schema validator, DQ success notifier, metrics publisher, Redshift maintenance.
- `dq/` — Data Quality runner (Python) with examples.
- `powerbi/` — Modeling & security notes; DAX measures; connection guidance.
- `docs/` — Architecture, warehouse overview, lineage, runbook, and SOPs.
- `docs/disaster_recovery.md` — Detailed DR plan, RTO/RPO, failover steps.
- `docs/performance_benchmarking.md` — Baselines and process for benchmark runs.
- `tests/` — SQL acceptance tests.
- `sample_data/` — CSV/JSON to smoke-test end-to-end.
- `sql/templates/` — COPY/UNLOAD SQL templates rendered per environment via `scripts/render_sql.py`.
- `scripts/` — SQL rendering, DQ metrics publisher, benchmarks, canary utilities.
- `notebooks/` — ML quickstart notebook for SageMaker.

> Configure `bucket_suffix`, Matillion/Redshift secrets, and optional PagerDuty + webhook in Terraform variables (`terraform.tfvars`). Use `scripts/render_sql.py` to render COPY/UNLOAD SQL with environment-specific values.

CI
- Terraform checks: fmt/validate/tflint/Checkov via `.github/workflows/terraform.yml`.
- DQ metrics: `.github/workflows/dq.yml`.
- Benchmarks: `.github/workflows/benchmarks.yml`.

ML Readiness
- Glue Catalog + Crawler for curated Parquet (toggle via Terraform).
- Lake Formation permissions (optional) to govern table access.
- Redshift UNLOAD templates to publish curated data to S3 Parquet.
- SageMaker notebook (optional) with example training and batch scoring scripts.

Getting Started
- See `docs/QUICKSTART.md` for hit-and-run deployment.
- See `docs/OPERATIONS.md` for day-to-day operations.
- See `docs/CI_CD.md` to wire CI/CD with AWS OIDC.
