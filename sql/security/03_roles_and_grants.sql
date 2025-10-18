CREATE ROLE IF NOT EXISTS r_branch_analyst;
CREATE ROLE IF NOT EXISTS r_data_admin;
GRANT USAGE ON SCHEMA mart, core, sec TO r_branch_analyst;
GRANT SELECT ON mart.v_fact_transactions_secure, core.dim_branch, core.dim_date, mart.v_dim_customer_secure TO r_branch_analyst;
GRANT USAGE ON SCHEMA mart, core, sec TO r_data_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA mart, core, sec TO r_data_admin;
-- GRANT r_branch_analyst TO USER "alice@bank";
-- GRANT r_data_admin     TO USER "admin@bank";
