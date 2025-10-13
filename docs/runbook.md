# Runbook (Daily)
00:05 files arrive → Lambda validates → 00:15 Matillion loads → 00:45 VACUUM/ANALYZE → 00:55 DQ checks → 01:05 Power BI refresh.
On failure: alert via SNS; follow quarantine/backfill SOP; re-run by ingest_date.
