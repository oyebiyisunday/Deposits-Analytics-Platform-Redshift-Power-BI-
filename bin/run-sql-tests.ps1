param(
  [Parameter(Mandatory=$true)][string]$Host,
  [Parameter(Mandatory=$true)][string]$User,
  [Parameter(Mandatory=$true)][string]$Password,
  [string]$Db = "dev",
  [int]$Port = 5439
)
$env:RS_HOST=$Host; $env:RS_USER=$User; $env:RS_PASSWORD=$Password; $env:RS_DB=$Db; $env:RS_PORT=$Port
python scripts/run_sql_tests.py
