param(
  [Parameter(Mandatory=$true)][ValidateSet('dev','stage','prod')][string]$Env,
  [Parameter(Mandatory=$true)][string]$BackendFile,
  [switch]$AutoApprove
)
$ErrorActionPreference = "Stop"
Push-Location "$PSScriptRoot\..\infra\terraform"
try { terraform --version | Out-Null } catch { throw "Terraform not found. Install Terraform >= 1.6" }

Write-Host "[Deploy] Environment: $Env"
if (-not (Test-Path $BackendFile)) { throw "Backend file not found: $BackendFile" }

terraform init -backend-config=$BackendFile | Out-Null
terraform fmt -recursive
terraform validate
if ($LASTEXITCODE -ne 0) { throw "terraform validate failed" }

terraform plan -var-file=terraform.tfvars -out=tfplan
if ($LASTEXITCODE -ne 0) { throw "terraform plan failed" }

if ($AutoApprove) {
  terraform apply -auto-approve tfplan
} else {
  Write-Host "Review plan in infra/terraform (tfplan). Run 'terraform apply tfplan' to proceed."
}
Pop-Location
