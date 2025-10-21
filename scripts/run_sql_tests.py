import os, sys, glob, psycopg2

"""
Lightweight SQL test runner for Redshift.
Executes SQL files under tests/sql and enforces simple zero-result policies
on selected files. Exits non-zero on failure.

Env: RS_HOST, RS_USER, RS_PASSWORD, RS_DB (opt), RS_PORT (opt)
"""

ENFORCE_ZERO = [
    "02_data_quality.sql",
    "04_amounts_non_negative.sql",
    "05_fk_integrity.sql",
]

def connect():
    return psycopg2.connect(
        host=os.environ["RS_HOST"],
        user=os.environ["RS_USER"],
        password=os.environ["RS_PASSWORD"],
        dbname=os.environ.get("RS_DB", "dev"),
        port=int(os.environ.get("RS_PORT", "5439")),
    )

def run_file(cur, path):
    sql = open(path, "r", encoding="utf-8").read()
    cur.execute(sql)
    try:
        rows = cur.fetchall()
    except Exception:
        rows = []
    return rows

def should_enforce_zero(path):
    return any(path.endswith(name) for name in ENFORCE_ZERO)

def main():
    files = sorted(glob.glob("tests/sql/*.sql"))
    if not files:
        print("No SQL tests found.")
        return 0
    conn = connect()
    cur = conn.cursor()
    failures = 0
    for f in files:
        rows = run_file(cur, f)
        print(f"== {f} ==")
        for r in rows:
            print(r)
        if should_enforce_zero(f):
            total = 0
            if rows and isinstance(rows[0], (list, tuple)):
                # Sum first column across rows
                total = sum(int(r[0]) for r in rows)
            if total != 0:
                print(f"FAIL: {f} expected total 0, got {total}")
                failures += 1
        else:
            print("INFO: no assertion for this file")
    conn.close()
    if failures:
        print(f"Tests failed: {failures}")
        return 1
    print("All enforced tests passed")
    return 0

if __name__ == "__main__":
    sys.exit(main())

