param(
  [Parameter(Mandatory=$true)][string]$Project,
  [Parameter(Mandatory=$true)][string]$BucketSuffix,
  [Parameter(Mandatory=$true)][string]$AccountId,
  [Parameter(Mandatory=$true)][string]$RoleName,
  [string]$ManifestName = "2025-10-01",
  [string]$OutDir = "dist/sql"
)
$ErrorActionPreference = "Stop"
python scripts/render_sql.py --project $Project --bucket-suffix $BucketSuffix --aws-account-id $AccountId --redshift-role-name $RoleName --manifest-name $ManifestName --out-dir $OutDir
