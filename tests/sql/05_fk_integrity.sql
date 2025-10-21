SELECT COUNT(*) AS orphan_accounts
FROM mart.fact_transactions f
LEFT JOIN core.dim_account a ON a.account_sk = f.account_sk AND a.end_dt IS NULL
WHERE a.account_sk IS NULL;

UNION ALL

SELECT COUNT(*) AS orphan_customers
FROM mart.fact_transactions f
LEFT JOIN core.dim_customer c ON c.customer_sk = f.customer_sk AND c.end_dt IS NULL
WHERE c.customer_sk IS NULL;

UNION ALL

SELECT COUNT(*) AS orphan_branches
FROM mart.fact_transactions f
LEFT JOIN core.dim_branch b ON b.branch_sk = f.branch_sk AND b.end_dt IS NULL
WHERE b.branch_sk IS NULL;

