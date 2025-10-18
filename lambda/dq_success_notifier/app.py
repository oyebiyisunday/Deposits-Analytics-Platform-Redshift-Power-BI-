import os, json, urllib.request
WEBHOOK_URL=os.environ.get("WEBHOOK_URL"); ENV=os.environ.get("ENV","prod")
def post(text):
    if not WEBHOOK_URL: return {"status":"no-webhook"}
    data=json.dumps({"text":text}).encode("utf-8")
    req=urllib.request.Request(WEBHOOK_URL,data=data,headers={"Content-Type":"application/json"})
    with urllib.request.urlopen(req) as r: return {"status":r.status}
def lambda_handler(event, context):
    return post(f"✅ [{ENV}] Data Quality checks passed. Data is ready.")