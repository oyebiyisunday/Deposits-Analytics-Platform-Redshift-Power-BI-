CREATE SCHEMA IF NOT EXISTS sec;
CREATE TABLE IF NOT EXISTS sec.user_scope (username VARCHAR(128) PRIMARY KEY, region_code VARCHAR(32), branch_ids VARCHAR(4000));
CREATE OR REPLACE VIEW sec.v_user_scope_expanded AS
SELECT username, region_code, TRIM(x) AS branch_id
FROM sec.user_scope, LATERAL SPLIT_TO_ARRAY(branch_ids, ',') AS s(x)
WHERE TRIM(x) <> '';
CREATE OR REPLACE VIEW sec.v_fact_txn_with_branch AS
SELECT f.*, db.branch_id FROM mart.fact_transactions f JOIN core.dim_branch db ON db.branch_sk=f.branch_sk AND db.end_dt IS NULL;
CREATE RLS POLICY pol_fact_txn_branch
ON sec.v_fact_txn_with_branch
USING (EXISTS (SELECT 1 FROM sec.v_user_scope_expanded u WHERE u.username=CURRENT_USER AND u.branch_id=sec.v_fact_txn_with_branch.branch_id));
ALTER VIEW sec.v_fact_txn_with_branch ENABLE RLS;
ALTER VIEW sec.v_fact_txn_with_branch ATTACH RLS POLICY pol_fact_txn_branch;
