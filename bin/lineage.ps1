param(
  [string]$Out = "dist/lineage.json"
)
$ErrorActionPreference = "Stop"
python scripts/lineage_capture.py --out $Out
Write-Host "Lineage written to $Out"
