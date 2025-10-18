import os, json, psycopg2, pandas as pd
import great_expectations as ge

"""
Lightweight Great Expectations runner for Redshift.
Runs a few core expectations and emits a JSON result + nonzero exit on failure.
Env: RS_HOST, RS_USER, RS_PASSWORD, RS_DB (opt), RS_PORT (opt)
"""

CHECK_SQL = """
SELECT txn_id, amount_usd
FROM mart.fact_transactions
LIMIT 10000
"""

def main():
    conn = psycopg2.connect(
        host=os.environ["RS_HOST"], user=os.environ["RS_USER"], password=os.environ["RS_PASSWORD"],
        dbname=os.environ.get("RS_DB","dev"), port=int(os.environ.get("RS_PORT","5439"))
    )
    df = pd.read_sql(CHECK_SQL, conn)
    gdf = ge.from_pandas(df)

    results = []
    res = gdf.expect_column_values_to_not_be_null("amount_usd")
    results.append({"check":"amount_usd_not_null","success": bool(res["success"])})

    # More expectations can be added here as needed

    ok = all(r["success"] for r in results)
    print(json.dumps({"ok": ok, "results": results}, indent=2))
    if not ok:
        raise SystemExit(1)

if __name__ == "__main__":
    main()

