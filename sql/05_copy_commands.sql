COPY stage.accounts_raw
FROM 's3://bank-deposits-mart-final-raw-<unique>/sqlserver/accounts/'
CREDENTIALS 'aws_iam_role=arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/RedshiftS3ReadRole'
CSV IGNOREHEADER 1 TIMEFORMAT 'auto' ACCEPTINVCHARS TRUNCATECOLUMNS;

COPY stage.transactions_raw
FROM 's3://bank-deposits-mart-final-raw-<unique>/sqlserver/transactions/'
CREDENTIALS 'aws_iam_role=arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/RedshiftS3ReadRole'
CSV IGNOREHEADER 1 TIMEFORMAT 'auto' ACCEPTINVCHARS TRUNCATECOLUMNS;

COPY stage.branch_targets_raw
FROM 's3://bank-deposits-mart-final-raw-<unique>/files/branch_targets/'
CREDENTIALS 'aws_iam_role=arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/RedshiftS3ReadRole'
CSV IGNOREHEADER 1 TIMEFORMAT 'auto';

COPY stage.exchange_rates_raw
FROM 's3://bank-deposits-mart-final-raw-<unique>/api/exchange_rates/'
CREDENTIALS 'aws_iam_role=arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/RedshiftS3ReadRole'
JSON 'auto';
