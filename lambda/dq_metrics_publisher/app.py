import os, json, boto3

CW = boto3.client("cloudwatch")
NAMESPACE = os.environ.get("METRIC_NAMESPACE", "custom/DQ")

def publish_metric(name: str, value: float, dims: dict | None = None, unit: str = "Count"):
  dims_list = [{"Name": k, "Value": str(v)} for k, v in (dims or {}).items()]
  CW.put_metric_data(
    Namespace=NAMESPACE,
    MetricData=[{"MetricName": name, "Value": value, "Unit": unit, "Dimensions": dims_list}]
  )

def lambda_handler(event, context):
  # Event can be a list of DQ check results or a summary
  # Example: [{"check":"Null USD amounts","actual":0,"expected":0,"ok":true}]
  try:
    results = event if isinstance(event, list) else event.get("results", [])
  except Exception:
    results = []

  failures = 0
  for r in results:
    ok = bool(r.get("ok", False))
    publish_metric("DQCheck", 0 if ok else 1, dims={"Check": r.get("check", "unknown")})
    if not ok:
      failures += 1

  publish_metric("DQFailures", failures)
  publish_metric("DQPassed", 1 if failures == 0 else 0)

  return {"status": "ok", "failures": failures}

