#!/usr/bin/env bash
set -euo pipefail
PROJECT="${1:?Usage: render-sql.sh <project> <bucket_suffix> <aws_account_id> <redshift_role_name> [manifest_name] [out_dir]>}"
BUCKET_SUFFIX="${2:?}"
ACCOUNT_ID="${3:?}"
ROLE_NAME="${4:?}"
MANIFEST_NAME="${5:-2025-10-01}"
OUT_DIR="${6:-dist/sql}"

python3 scripts/render_sql.py \
  --project "${PROJECT}" \
  --bucket-suffix "${BUCKET_SUFFIX}" \
  --aws-account-id "${ACCOUNT_ID}" \
  --redshift-role-name "${ROLE_NAME}" \
  --manifest-name "${MANIFEST_NAME}" \
  --out-dir "${OUT_DIR}"
