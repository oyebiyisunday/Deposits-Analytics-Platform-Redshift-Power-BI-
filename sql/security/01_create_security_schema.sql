CREATE SCHEMA IF NOT EXISTS sec;
-- Map users to allowed region/branches (comma-separated for simplicity)
CREATE TABLE IF NOT EXISTS sec.user_scope (
  username   VARCHAR(128) PRIMARY KEY,
  region_code VARCHAR(32),
  branch_ids VARCHAR(4000)
);

-- Simple admin list for unmasked access
CREATE TABLE IF NOT EXISTS sec.admin_users (
  username VARCHAR(128) PRIMARY KEY
);

-- Expand branch_id list into rows for join filtering
CREATE OR REPLACE VIEW sec.v_user_scope_expanded AS
SELECT username, region_code, TRIM(x) AS branch_id
FROM sec.user_scope, LATERAL SPLIT_TO_ARRAY(branch_ids, ',') AS s(x)
WHERE TRIM(x) <> '';

-- Helper view with branch_id for fact
CREATE OR REPLACE VIEW sec.v_fact_txn_with_branch AS
SELECT f.*, db.branch_id
FROM mart.fact_transactions f
JOIN core.dim_branch db ON db.branch_sk=f.branch_sk AND db.end_dt IS NULL;
