-- Data canary checks: returns 0 if pass, non-zero on failure via wrapper
-- 1) Freshness: ensure at least one txn in last 30 days
SELECT CASE WHEN MAX(txn_date_sk) >= (SELECT date_sk FROM core.dim_date WHERE full_date >= DATEADD(day,-30,CURRENT_DATE) ORDER BY full_date DESC LIMIT 1)
            THEN 0 ELSE 1 END AS freshness_bad
FROM mart.fact_transactions;

-- 2) No NULL USD amounts
SELECT CASE WHEN COUNT(*)=0 THEN 0 ELSE 1 END AS null_amounts
FROM mart.fact_transactions WHERE amount_usd IS NULL;

