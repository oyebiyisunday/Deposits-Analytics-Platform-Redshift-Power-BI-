import os, time, json, psycopg2, boto3

CW = boto3.client("cloudwatch")

def put(ns, name, val, unit="Count", dims=None):
    CW.put_metric_data(Namespace=ns, MetricData=[{
        "MetricName": name, "Value": float(val), "Unit": unit,
        "Dimensions": [{"Name": k, "Value": str(v)} for k,v in (dims or {}).items()]
    }])

def run_query(cur, sql):
    t0 = time.time()
    cur.execute(sql)
    try:
        cur.fetchall()
    except Exception:
        pass
    return (time.time() - t0) * 1000.0

def main():
    ns = os.environ.get("BENCH_NAMESPACE", f"{os.environ.get('PROJECT','bank-analytics-platform')}/Benchmarks")
    conn = psycopg2.connect(
        host=os.environ["RS_HOST"], user=os.environ["RS_USER"], password=os.environ["RS_PASSWORD"],
        dbname=os.environ.get("RS_DB","dev"), port=int(os.environ.get("RS_PORT","5439"))
    )
    cur = conn.cursor()
    # Disable result cache to get consistent timings
    cur.execute("set enable_result_cache_for_session=false;")

    queries = [
        ("QueryPerf", open("sql/benchmarks/02_query_perf.sql","r",encoding="utf-8").read()),
    ]
    for name, sql in queries:
        ms = run_query(cur, sql)
        put(ns, "QueryLatencyMs", ms, unit="Milliseconds", dims={"Query": name})

    # Table stats
    cur.execute(open("sql/benchmarks/03_table_stats.sql","r",encoding="utf-8").read())
    rows = cur.fetchall()
    put(ns, "Tables", len(rows))
    print(json.dumps({"benchmarks": len(queries), "tables": len(rows)}, indent=2))

if __name__ == "__main__":
    main()
