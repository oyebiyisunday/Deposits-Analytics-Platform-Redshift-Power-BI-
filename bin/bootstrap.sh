#!/usr/bin/env bash
set -euo pipefail
REGION="${1:-us-east-1}"
BUCKET_NAME="${2:?Usage: bootstrap.sh <region> <bucket_name> [lock_table]>}"
LOCK_TABLE="${3:-terraform-state-locks}"

cd "$(dirname "$0")/../infra/bootstrap"
terraform init >/dev/null
terraform apply -auto-approve -var "region=${REGION}" -var "bucket_name=${BUCKET_NAME}" -var "dynamodb_table=${LOCK_TABLE}"
