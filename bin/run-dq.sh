#!/usr/bin/env bash
set -euo pipefail
HOST="${1:?Usage: run-dq.sh <host> <user> <password> [db] [port]>}"
USER="${2:?}"
PASS="${3:?}"
DB="${4:-dev}"
PORT="${5:-5439}"
RS_HOST="$HOST" RS_USER="$USER" RS_PASSWORD="$PASS" RS_DB="$DB" RS_PORT="$PORT" \
  python3 dq/runner.py
