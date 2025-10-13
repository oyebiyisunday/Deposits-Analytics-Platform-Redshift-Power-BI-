CREATE TABLE IF NOT EXISTS core.dim_branch (
  branch_sk BIGINT IDENTITY(1,1), branch_id VARCHAR(16) ENCODE ZSTD,
  branch_name VARCHAR(200) ENCODE ZSTD, region VARCHAR(100) ENCODE ZSTD,
  is_active BOOLEAN, effective_dt DATE, end_dt DATE,
  CONSTRAINT pk_dim_branch PRIMARY KEY (branch_sk)
);
CREATE TABLE IF NOT EXISTS core.dim_account (
  account_sk BIGINT IDENTITY(1,1), account_id VARCHAR(32) ENCODE ZSTD,
  customer_id VARCHAR(32) ENCODE ZSTD, branch_sk BIGINT,
  account_type VARCHAR(20) ENCODE ZSTD, open_dt DATE, status VARCHAR(16) ENCODE ZSTD,
  currency_code VARCHAR(3), effective_dt DATE, end_dt DATE,
  CONSTRAINT pk_dim_account PRIMARY KEY (account_sk)
);
CREATE TABLE IF NOT EXISTS core.dim_customer (
  customer_sk BIGINT IDENTITY(1,1), customer_id VARCHAR(32) ENCODE ZSTD,
  full_name VARCHAR(200), email VARCHAR(320), customer_segment VARCHAR(50),
  kyc_flag BOOLEAN, effective_dt DATE, end_dt DATE,
  CONSTRAINT pk_dim_customer PRIMARY KEY (customer_sk)
);
CREATE TABLE IF NOT EXISTS core.dim_date (
  date_sk INTEGER NOT NULL, full_date DATE NOT NULL, yyyy_mm CHAR(7),
  day_of_week SMALLINT, month_num SMALLINT, quarter_num SMALLINT, year_num SMALLINT,
  CONSTRAINT pk_dim_date PRIMARY KEY (date_sk)
);
CREATE TABLE IF NOT EXISTS core.dim_fx (
  fx_sk BIGINT IDENTITY(1,1), as_of_date DATE, base_ccy VARCHAR(3),
  quote_ccy VARCHAR(3), rate DECIMAL(18,8),
  CONSTRAINT uq_dim_fx UNIQUE(as_of_date, base_ccy, quote_ccy)
);
