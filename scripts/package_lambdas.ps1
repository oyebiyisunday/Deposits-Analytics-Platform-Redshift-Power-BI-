Param(
  [string]$OutDir = "dist"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Function Zip-Lambda($name, $srcDir) {
  $zipPath = Join-Path $OutDir "$name.zip"
  if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
  Push-Location $srcDir
  try {
    Compress-Archive -Path * -DestinationPath (Resolve-Path $zipPath) -Force
  } finally {
    Pop-Location
  }
  Write-Output "Built $zipPath"
}

Zip-Lambda -name "matillion_trigger" -srcDir (Join-Path "lambda" "matillion_trigger")
Zip-Lambda -name "retry_handler" -srcDir (Join-Path "lambda" "retry_handler")
Zip-Lambda -name "validate_schema_prod" -srcDir (Join-Path "lambda" "validate_schema_prod")
Zip-Lambda -name "dq_success_notifier" -srcDir (Join-Path "lambda" "dq_success_notifier")
Zip-Lambda -name "dq_metrics_publisher" -srcDir (Join-Path "lambda" "dq_metrics_publisher")

Write-Output "Done. Copy zips next to Terraform or update paths accordingly."
