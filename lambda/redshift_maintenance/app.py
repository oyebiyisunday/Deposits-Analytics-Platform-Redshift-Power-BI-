import os, boto3, json

RS = boto3.client("redshift-data")

CLUSTER_ID = os.environ.get("CLUSTER_IDENTIFIER")
DATABASE   = os.environ.get("DATABASE", "dev")
SECRET_ARN = os.environ.get("SECRET_ARN")

STATEMENTS = [
  "VACUUM",
  "ANALYZE"
]

def exec_sql(sql):
  resp = RS.execute_statement(
    ClusterIdentifier=CLUSTER_ID,
    Database=DATABASE,
    SecretArn=SECRET_ARN,
    Sql=sql
  )
  return resp.get("Id")

def lambda_handler(event, context):
  executed = []
  for s in STATEMENTS:
    try:
      qid = exec_sql(s)
      executed.append({"sql": s, "qid": qid})
    except Exception as e:
      executed.append({"sql": s, "error": str(e)})
  return {"executed": executed}

