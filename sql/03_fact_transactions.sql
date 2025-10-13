CREATE TABLE IF NOT EXISTS mart.fact_transactions (
  txn_id VARCHAR(40), account_sk BIGINT, customer_sk BIGINT, branch_sk BIGINT,
  txn_date_sk INTEGER, amount_native DECIMAL(18,2), amount_usd DECIMAL(18,2),
  txn_type VARCHAR(20), channel VARCHAR(20), currency_code VARCHAR(3),
  load_dt TIMESTAMP DEFAULT GETDATE()
)
DISTKEY (account_sk)
SORTKEY (txn_date_sk, branch_sk);
