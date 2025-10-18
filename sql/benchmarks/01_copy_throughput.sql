-- Measures COPY throughput from S3 to stage.transactions_raw (requires prefix to be loaded)
-- Run with: set enable_result_cache_for_session=false;
COPY stage.transactions_raw
FROM 's3://your-bucket/sqlserver/transactions/benchmark/'
CREDENTIALS 'aws_iam_role=arn:aws:iam::123456789012:role/RedshiftS3ReadRole'
CSV IGNOREHEADER 1 TIMEFORMAT 'auto' ACCEPTINVCHARS;

