#!/usr/bin/env bash
set -euo pipefail
ENV="${1:?Usage: deploy.sh <env: dev|stage|prod> <backend_file> [-y]>}"
BACKEND_FILE="${2:?Usage: deploy.sh <env> <backend_file> [-y]>}"
AUTO="${3:-}"

cd "$(dirname "$0")/../infra/terraform"
terraform init -backend-config="${BACKEND_FILE}" >/dev/null
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan
if [[ "${AUTO}" == "-y" ]]; then
  terraform apply -auto-approve tfplan
else
  echo "Review plan (tfplan). Run 'terraform apply tfplan' to proceed."
fi
