Security Policy

Reporting a Vulnerability
- Please do not open public issues for security problems.
- Email the maintainers or use your organization’s responsible disclosure channel.

Secrets & Sensitive Data
- No real credentials, tokens, or endpoints should be committed.
- Use GitHub Secrets for CI and AWS Secrets Manager for runtime.
- Do not commit `terraform.tfvars` files with sensitive values.

Data
- Sample data under `sample_data/` is synthetic and for testing only.
- Do not include real customer data in this repository.

Supply Chain
- CI runs static checks (Terraform fmt/validate/TFLint/Checkov), secret scans (gitleaks), and DQ/benchmarks where configured.

