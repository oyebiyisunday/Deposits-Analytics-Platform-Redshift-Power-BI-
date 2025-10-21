param(
  [string]$Region = "us-east-1",
  [Parameter(Mandatory=$true)][string]$BucketName,
  [string]$LockTable = "terraform-state-locks"
)
$ErrorActionPreference = "Stop"
Push-Location "$PSScriptRoot\..\infra\bootstrap"
try {
  terraform --version | Out-Null
} catch { throw "Terraform not found. Install Terraform >= 1.6" }

terraform init | Out-Null
terraform apply -auto-approve -var "region=$Region" -var "bucket_name=$BucketName" -var "dynamodb_table=$LockTable"
Pop-Location
