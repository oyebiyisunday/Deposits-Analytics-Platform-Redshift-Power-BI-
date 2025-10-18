-- Upserts & fact load (examples)
-- Branch
DELETE FROM core.dim_branch USING (SELECT DISTINCT branch_id FROM stage.accounts_raw) s
WHERE core.dim_branch.branch_id = s.branch_id AND core.dim_branch.end_dt IS NULL;
INSERT INTO core.dim_branch (branch_id, branch_name, region, is_active, effective_dt, end_dt)
SELECT DISTINCT a.branch_id, 'UNKNOWN', 'UNKNOWN', TRUE, CURRENT_DATE, NULL
FROM stage.accounts_raw a
LEFT JOIN core.dim_branch b ON a.branch_id=b.branch_id AND b.end_dt IS NULL
WHERE b.branch_id IS NULL;

-- Accounts
INSERT INTO core.dim_account (account_id, customer_id, branch_sk, account_type, open_dt, status, currency_code, effective_dt, end_dt)
SELECT a.account_id, a.customer_id, b.branch_sk, a.account_type, a.account_open_dt, a.status, a.currency_code, CURRENT_DATE, NULL
FROM stage.accounts_raw a
JOIN core.dim_branch b ON a.branch_id = b.branch_id AND b.end_dt IS NULL
LEFT JOIN core.dim_account d ON d.account_id=a.account_id AND d.end_dt IS NULL
WHERE d.account_id IS NULL;

-- Fact with FX normalization
INSERT INTO mart.fact_transactions (
  txn_id, account_sk, customer_sk, branch_sk, txn_date_sk,
  amount_native, amount_usd, txn_type, channel, currency_code
)
SELECT t.txn_id, da.account_sk, dc.customer_sk, db.branch_sk, dd.date_sk,
       t.amount, (t.amount * COALESCE(fx.rate,1.0)) as amount_usd,
       t.txn_type, t.channel, t.currency_code
FROM stage.transactions_raw t
JOIN core.dim_account  da ON da.account_id=t.account_id AND da.end_dt IS NULL
JOIN core.dim_customer dc ON dc.customer_id=da.customer_id AND dc.end_dt IS NULL
JOIN core.dim_branch   db ON db.branch_sk=da.branch_sk AND db.end_dt IS NULL
JOIN core.dim_date     dd ON dd.full_date = CAST(t.txn_ts AS DATE)
LEFT JOIN core.dim_fx  fx ON fx.as_of_date=CAST(t.txn_ts AS DATE) AND fx.base_ccy=t.currency_code AND fx.quote_ccy='USD';
