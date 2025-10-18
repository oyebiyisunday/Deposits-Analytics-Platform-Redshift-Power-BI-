COPY stage.transactions_raw
FROM 's3://bank-deposits-mart-final-raw-<unique>/sqlserver/transactions/manifest/2025-10-01.manifest'
CREDENTIALS 'aws_iam_role=arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/RedshiftS3ReadRole'
MANIFEST
CSV IGNOREHEADER 1 TIMEFORMAT 'auto' ACCEPTINVCHARS;
