# Warehouse Overview (Redshift)
Schemas: stage (raw copy), core (conformed dims), mart (facts for BI).
Key tables: core.dim_branch, core.dim_account, core.dim_customer, core.dim_date, core.dim_fx, mart.fact_transactions.
Load order: COPY → stage → conformance → SCD dims → fact → VACUUM/ANALYZE.
