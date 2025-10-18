import os, sys, psycopg2

def main():
    conn=psycopg2.connect(host=os.environ["RS_HOST"],user=os.environ["RS_USER"],password=os.environ["RS_PASSWORD"],dbname=os.environ.get("RS_DB","dev"),port=int(os.environ.get("RS_PORT","5439")))
    cur=conn.cursor()
    with open('scripts/canary.sql','r',encoding='utf-8') as f:
        sql = f.read()
    # execute statements split by semicolon
    failures = 0
    for stmt in [s.strip() for s in sql.split(';') if s.strip()]:
        cur.execute(stmt)
        row = cur.fetchone()
        if row and row[0] and int(row[0]) != 0:
            failures += 1
    print(f"canary_failures={failures}")
    sys.exit(1 if failures>0 else 0)

if __name__ == '__main__':
    main()

