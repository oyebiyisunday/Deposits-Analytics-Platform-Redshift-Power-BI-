CREATE MASKING POLICY IF NOT EXISTS mask_name_email AS
(FULL_NAME VARCHAR(200), EMAIL VARCHAR(320))
RETURNS (VARCHAR(200), VARCHAR(320)) ->
CASE WHEN HAS_ROLE('r_data_admin') THEN (FULL_NAME, EMAIL)
     ELSE (LEFT(FULL_NAME,1) || '*****', '*****@*****.com')
END;
CREATE OR REPLACE VIEW mart.v_dim_customer_secure AS
SELECT customer_sk, customer_id,
       APPLY_MASKING_POLICY(mask_name_email ON (full_name, email)) AS (full_name, email),
       customer_segment, kyc_flag
FROM core.dim_customer;
CREATE OR REPLACE VIEW mart.v_fact_transactions_secure AS
SELECT txn_id, account_sk, customer_sk, branch_sk, txn_date_sk,
       amount_native, amount_usd, txn_type, channel, currency_code, load_dt
FROM sec.v_fact_txn_with_branch;
