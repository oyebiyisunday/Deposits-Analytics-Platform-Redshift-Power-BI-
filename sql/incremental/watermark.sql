CREATE TABLE IF NOT EXISTS core.load_watermarks (table_name VARCHAR(100) PRIMARY KEY, last_txn_ts TIMESTAMP);
-- Load new rows using last watermark then update it.
