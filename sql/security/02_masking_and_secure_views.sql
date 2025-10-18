-- Redshift-compatible masking via CASE + admin list
CREATE OR REPLACE VIEW mart.v_dim_customer_secure AS
SELECT
  customer_sk,
  customer_id,
  CASE WHEN EXISTS (SELECT 1 FROM sec.admin_users a WHERE a.username = CURRENT_USER)
       THEN full_name
       ELSE LEFT(full_name, 1) || '*****'
  END AS full_name,
  CASE WHEN EXISTS (SELECT 1 FROM sec.admin_users a WHERE a.username = CURRENT_USER)
       THEN email
       ELSE '*****@*****.com'
  END AS email,
  customer_segment,
  kyc_flag
FROM core.dim_customer;

-- Redshift-compatible row filtering via join to user scope
CREATE OR REPLACE VIEW mart.v_fact_transactions_secure AS
SELECT f.txn_id, f.account_sk, f.customer_sk, f.branch_sk, f.txn_date_sk,
       f.amount_native, f.amount_usd, f.txn_type, f.channel, f.currency_code, f.load_dt
FROM sec.v_fact_txn_with_branch f
JOIN sec.v_user_scope_expanded u
  ON u.username = CURRENT_USER AND u.branch_id = f.branch_id;
