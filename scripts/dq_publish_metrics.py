import os, json, boto3, subprocess, sys

"""
Runs dq/runner.py to compute checks, then publishes metrics to CloudWatch.
Requires env: RS_HOST, RS_USER, RS_PASSWORD (and optional RS_DB, RS_PORT).
AWS creds must allow cloudwatch:PutMetricData.
"""

def run_dq_checks() -> list:
    proc = subprocess.run([sys.executable, "dq/runner.py"], capture_output=True, text=True)
    out = proc.stdout.strip()
    # dq/runner.py prints JSON array
    try:
        results = json.loads(out)
    except json.JSONDecodeError:
        print("Failed to parse DQ output:", out)
        results = []
    return results

def publish(results: list, namespace: str):
    cw = boto3.client("cloudwatch")
    failures = 0
    for r in results:
        ok = bool(r.get("ok", False))
        if not ok:
            failures += 1
        cw.put_metric_data(
            Namespace=namespace,
            MetricData=[{
                "MetricName": "DQCheck",
                "Value": 0 if ok else 1,
                "Unit": "Count",
                "Dimensions": [{"Name": "Check", "Value": r.get("check", "unknown")}]
            }]
        )
    cw.put_metric_data(
        Namespace=namespace,
        MetricData=[
            {"MetricName": "DQFailures", "Value": failures, "Unit": "Count"},
            {"MetricName": "DQPassed", "Value": 1 if failures == 0 else 0, "Unit": "Count"},
        ]
    )
    print(json.dumps({"failures": failures, "count": len(results)}, indent=2))

def main():
    ns = os.environ.get("DQ_METRIC_NAMESPACE", f"{os.environ.get('PROJECT','bank-analytics-platform')}/DQ")
    results = run_dq_checks()
    publish(results, ns)

if __name__ == "__main__":
    main()
