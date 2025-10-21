# CI/CD â€” Deposits Analytics Platform

This project includes GitHub Actions for Terraform validation, Python static checks, and optional DQ checks. To enable deployments via OIDC, configure an AWS IAM role that trusts GitHub environments.

## Workflows included
- `.github/workflows/terraform.yml`: fmt + validate on PRs
- `.github/workflows/python-static.yml`: Python syntax checks on changed files
- `.github/workflows/dq.yml`: Manual DQ run with Redshift secrets (workflow_dispatch)

## OIDC to AWS (Deploy)
1. Create an IAM role `deploy-role` in AWS with a trust policy for GitHub OIDC (org/repo and branch/environment conditions).
2. Attach permissions for Terraform to manage target resources.
3. In GitHub, store the role ARN and region as workflow `env` or repository `secrets`.
4. Add a deploy workflow using `aws-actions/configure-aws-credentials@v4` and `hashicorp/setup-terraform@v3` to run `terraform plan/apply`.

> Tip: Start with `plan` on PRs and allow `apply` only on protected branches with approvals.


