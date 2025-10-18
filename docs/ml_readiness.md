ML Readiness and Pipeline

Components
- Glue Database + Crawler: catalogs curated S3 Parquet so Athena/SageMaker can discover datasets.
- Lake Formation (optional): centralized permissions on S3/Glue tables.
- Redshift UNLOAD: exports curated datasets to Parquet in the curated bucket.
- SageMaker Notebook: VPC-attached dev workspace with KMS and S3 access.
- Feature Store (optional): example feature group for account features (offline+online).

How to Enable
1) Terraform vars: set `enable_sagemaker_notebook=true`, `enable_feature_store=true`, and `enable_lake_formation=true` (with admins).
2) `terraform apply` in infra/terraform.
3) Render and run `dist/sql/unload_curated_parquet.sql` to publish Parquet.
4) Start the Glue crawler to catalog new tables.
5) Open the SageMaker notebook and run `notebooks/ml_quickstart.ipynb`.

Security
- All data remains KMS-encrypted; notebook uses private subnets and NAT/VPC endpoints.
- Lake Formation can restrict table/column access per principal.

