Performance Benchmarking Baselines

Goals
- Track COPY throughput, query latency, and freshness across releases.
- Detect regressions via CloudWatch metrics and CI benchmarks.

Baselines & SLOs
- COPY throughput: >= 50 MB/s per node on raw CSV loads (baseline adjustable).
- Transform latency: < 15 min end-to-end for daily partition.
- Query latency (P95): < 3s for top 10 BI queries.

Metrics to Capture
- CloudWatch: QueryDuration, WLMQueueLength, CPUUtilization, ConcurrencyScalingSACUSeconds.
- Custom: `Bench/CopyMBps`, `Bench/QueryLatencyMs:{QueryName}`, `Bench/RowsProcessed`.

Data & Queries
- Use `sql/benchmarks/*` for consistent runs:
  - 01_copy_throughput.sql
  - 02_query_perf.sql
  - 03_table_stats.sql

Process
1) Prepare sample data in S3 raw (1–10 GB CSVs).
2) Run benchmark workflow (`.github/workflows/benchmarks.yml`) with RS_* secrets.
3) Confirm metrics in `${project}/Benchmarks` namespace; compare to previous runs.

Tuning Checklist
- DIST/SORT keys aligned with top queries.
- VACUUM/ANALYZE cadence after large loads.
- WLM queues sized for concurrency; enable Concurrency Scaling.
- Spectrum vs staged loads when applicable.

