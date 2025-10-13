import os, json, sys, psycopg2
CHECKS=[
 ("Null USD amounts","SELECT COUNT(*) FROM mart.fact_transactions WHERE amount_usd IS NULL;",0),
 ("Orphan accounts","SELECT COUNT(*) FROM mart.fact_transactions f LEFT JOIN core.dim_account a ON a.account_sk=f.account_sk AND a.end_dt IS NULL WHERE a.account_sk IS NULL;",0),
]
def main():
  conn=psycopg2.connect(host=os.environ["RS_HOST"],user=os.environ["RS_USER"],password=os.environ["RS_PASSWORD"],dbname=os.environ.get("RS_DB","dev"),port=int(os.environ.get("RS_PORT","5439")))
  cur=conn.cursor(); results=[]
  for name,sql,exp in CHECKS:
    cur.execute(sql); val=cur.fetchone()[0]; results.append({"check":name,"actual":int(val),"expected":exp,"ok":int(val)==exp})
  print(json.dumps(results,indent=2)); sys.exit(1 if any(not r["ok"] for r in results) else 0)
if __name__=="__main__": main()