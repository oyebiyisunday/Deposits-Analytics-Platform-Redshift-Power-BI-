import os, boto3, time

RS = boto3.client("redshift")
CW = boto3.client("cloudwatch")

CLUSTER_ID = os.environ.get("CLUSTER_IDENTIFIER")
NAMESPACE = os.environ.get("METRIC_NAMESPACE", "custom/Backup")

def latest_snapshot_age_hours(cluster_id: str) -> float:
    snaps = RS.describe_cluster_snapshots(
        ClusterIdentifier=cluster_id,
        SortingEntities=[{"AttributeName": "CREATE_TIME", "SortOrder": "DESC"}],
        MaxRecords=20,
    ).get("Snapshots", [])
    if not snaps:
        return 9999.0
    latest = max(snaps, key=lambda s: s["SnapshotCreateTime"])  # type: ignore
    now = time.time()
    age = now - latest["SnapshotCreateTime"].timestamp()
    return age / 3600.0

def publish(name: str, value: float, dims: dict | None = None):
    dims_list = [{"Name": k, "Value": str(v)} for k, v in (dims or {}).items()]
    CW.put_metric_data(
        Namespace=NAMESPACE,
        MetricData=[{"MetricName": name, "Value": value, "Unit": "None", "Dimensions": dims_list}],
    )

def lambda_handler(event, context):
    age = latest_snapshot_age_hours(CLUSTER_ID)
    publish("BackupAgeHours", age, {"Cluster": CLUSTER_ID})
    return {"age_hours": age}

