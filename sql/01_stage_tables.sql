CREATE TABLE IF NOT EXISTS stage.accounts_raw (
  account_id VARCHAR(32), customer_id VARCHAR(32), branch_id VARCHAR(16),
  account_open_dt DATE, account_type VARCHAR(20), currency_code VARCHAR(3),
  current_balance DECIMAL(18,2), status VARCHAR(16),
  _ingest_dt TIMESTAMP DEFAULT GETDATE()
);
CREATE TABLE IF NOT EXISTS stage.transactions_raw (
  txn_id VARCHAR(40), account_id VARCHAR(32), txn_ts TIMESTAMP, amount DECIMAL(18,2),
  txn_type VARCHAR(20), currency_code VARCHAR(3), channel VARCHAR(20),
  _ingest_dt TIMESTAMP DEFAULT GETDATE()
);
CREATE TABLE IF NOT EXISTS stage.branch_targets_raw (
  branch_id VARCHAR(16), target_month DATE, deposits_target DECIMAL(18,2),
  _ingest_dt TIMESTAMP DEFAULT GETDATE()
);
CREATE TABLE IF NOT EXISTS stage.exchange_rates_raw (
  as_of_date DATE, base_ccy VARCHAR(3), quote_ccy VARCHAR(3), rate DECIMAL(18,8),
  _ingest_dt TIMESTAMP DEFAULT GETDATE()
);
