-- Hours since most recent load
SELECT DATEDIFF(hour, MAX(load_dt), GETDATE()) FROM mart.fact_transactions;

