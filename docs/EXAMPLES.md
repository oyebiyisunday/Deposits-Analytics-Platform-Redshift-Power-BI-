# Implementation Examples

## COPY Examples
Render with `bin/render-sql.ps1` or `.sh`, then run:
```
\i dist/sql/05_copy_commands.sql
```

## Matillion Trigger Event
Invoke Lambda with payload:
```
{
  "job_name": "J_ORCH_Load_Deposits",
  "project": "<matillion-project>",
  "group": "<group>",
  "version": "<version>"
}
```

## DQ Runner
```
export RS_HOST=... RS_USER=... RS_PASSWORD=...
python dq/runner.py
```

## Publishing DQ Metrics
```
aws lambda invoke \
  --function-name <project>-dq-metrics \
  --payload '[{"check":"Null USD amounts","actual":0,"expected":0,"ok":true}]' \
  out.json
```

