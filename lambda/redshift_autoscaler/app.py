import os, time, boto3

CW = boto3.client("cloudwatch")
RS = boto3.client("redshift")

CLUSTER_ID = os.environ.get("CLUSTER_IDENTIFIER")
MIN_NODES = int(os.environ.get("MIN_NODES", "1"))
MAX_NODES = int(os.environ.get("MAX_NODES", "2"))
WLM_THRESHOLD = float(os.environ.get("WLM_THRESHOLD", "5"))
CPU_THRESHOLD = float(os.environ.get("CPU_THRESHOLD", "85"))

def metric_avg(namespace, metric, dimensions, minutes=15):
    end = int(time.time())
    start = end - minutes * 60
    resp = CW.get_metric_statistics(
        Namespace=namespace,
        MetricName=metric,
        Dimensions=[{"Name": k, "Value": v} for k,v in dimensions.items()],
        StartTime=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(start)),
        EndTime=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(end)),
        Period=300,
        Statistics=["Average"],
    )
    dps = resp.get("Datapoints", [])
    if not dps:
        return 0.0
    return sum(dp["Average"] for dp in dps) / len(dps)

def current_nodes():
    desc = RS.describe_clusters(ClusterIdentifier=CLUSTER_ID)["Clusters"][0]
    return desc.get("NumberOfNodes", 1)

def resize(nodes):
    RS.modify_cluster(ClusterIdentifier=CLUSTER_ID, NumberOfNodes=nodes)

def lambda_handler(event, context):
    dims = {"ClusterIdentifier": CLUSTER_ID}
    wlm = metric_avg("AWS/Redshift", "WLMQueueLength", dims)
    cpu = metric_avg("AWS/Redshift", "CPUUtilization", dims)
    nodes = current_nodes()
    target = nodes
    if (wlm > WLM_THRESHOLD or cpu > CPU_THRESHOLD) and nodes < MAX_NODES:
        target = min(MAX_NODES, nodes + 1)
    elif (wlm < 1 and cpu < 40) and nodes > MIN_NODES:
        target = max(MIN_NODES, nodes - 1)

    if target != nodes:
        resize(target)
        return {"action": "resize", "from": nodes, "to": target, "wlm": wlm, "cpu": cpu}
    return {"action": "none", "nodes": nodes, "wlm": wlm, "cpu": cpu}

