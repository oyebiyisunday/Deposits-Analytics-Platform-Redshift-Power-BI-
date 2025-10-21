# Quickstart — Deposits Analytics Platform

Production‑ready deployment steps with minimal inputs. After connecting an AWS account, run the bootstrap and deploy scripts, then validate the pipeline.

## Prerequisites
- AWS account with admin permissions (bootstrap) and least‑privileged role for deployment
- Tools: Terraform >= 1.6, AWS CLI, Python 3.12
- Repo cloned locally; set AWS credentials (profile or env)

## 1) Bootstrap Terraform backend (one‑time)
Use a globally unique S3 bucket for Terraform state and a DynamoDB table for locks.

Windows (PowerShell)
- `bin/bootstrap.ps1 -Region us-east-1 -BucketName <unique-backend-bucket> -LockTable terraform-state-locks`

macOS/Linux
- `bash bin/bootstrap.sh us-east-1 <unique-backend-bucket> terraform-state-locks`

Copy outputs into an environment backend config, e.g. `infra/terraform/backend-dev.hcl.example` → `backend-dev.hcl`.

## 2) Configure environment variables
Copy `infra/terraform/terraform.tfvars.example` to `infra/terraform/terraform.tfvars` and set values:
- `region`, `project`, `bucket_suffix`
- Redshift credentials (temporary; consider Secrets rotation)
- Networking and optional toggles (PagerDuty, Lake Formation, PgBouncer, etc.)

## 3) Deploy the platform
Windows (PowerShell)
- `bin\deploy.ps1 -Env dev -BackendFile infra/terraform/backend-dev.hcl -AutoApprove`

macOS/Linux
- `bash bin/deploy.sh dev infra/terraform/backend-dev.hcl -y`

What this does
- Packages Lambda functions (hashicorp/archive)
- Provisions VPC, KMS, S3 (raw/stage/curated + logs), Redshift (RA3), IAM
- Creates Lambdas (schema validation, DQ metrics, maintenance), schedules, alarms, dashboards

## 4) Configure Secrets
Store credentials for Matillion and Redshift as noted in `DEPLOYMENT_GUIDE.md` (optional Matillion).

## 5) Load sample data and run checks (optional)
- Upload sample files from `sample_data/` into the `raw` bucket paths
- Render SQL templates: `bin/render-sql.ps1 -Project <project> -BucketSuffix <suffix> -AccountId <acct> -RoleName <role>`
- Run DQ checks: `python dq/runner.py` (set RS_HOST/USER/PASSWORD)

## 6) Connect Power BI
Use secure views and the Redshift endpoint output in Terraform. See `powerbi/` notes.

## 7) CI/CD (optional)
GitHub Actions included for Terraform validate, Python syntax, and manual DQ. For deploy via OIDC, see `docs/CI_CD.md`.

## Troubleshooting
- `terraform plan` errors: ensure `hashicorp/archive` provider is present (already required in providers.tf).
- Lambda packaging: Terraform will zip from `lambda/*` directories automatically.
- S3 access/logging: Access logs written to `<project>-logs-<suffix>` bucket.
