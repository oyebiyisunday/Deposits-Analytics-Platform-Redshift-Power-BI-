-- Benchmark query patterns against mart.fact_transactions
set enable_result_cache_for_session=false;
EXPLAIN SELECT b.region,d.year_num,d.month_num,
       SUM(CASE WHEN f.txn_type='deposit' THEN f.amount_usd ELSE 0 END)
FROM mart.fact_transactions f
JOIN core.dim_branch b ON b.branch_sk=f.branch_sk
JOIN core.dim_date   d ON d.date_sk=f.txn_date_sk
WHERE d.full_date>=DATEADD(year,-1,CURRENT_DATE)
GROUP BY 1,2,3;

SELECT COUNT(*) FROM mart.fact_transactions;

