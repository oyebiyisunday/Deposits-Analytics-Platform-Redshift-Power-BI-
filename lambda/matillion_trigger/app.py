import os, json, urllib.request, base64

BASE_URL = os.environ.get("MATILLION_BASE_URL", "")
USER = os.environ.get("MATILLION_USER", "")
PASSWORD = os.environ.get("MATILLION_PASSWORD", "")

def call_matillion(job_name: str, project: str = None, group: str = None, version: str = None):
    if not BASE_URL or not USER or not PASSWORD:
        return {"status": "skipped", "reason": "missing_credentials"}
    # Minimal, best-effort call. Adjust endpoint/path to your Matillion instance.
    payload = {"name": job_name}
    if project: payload["project"] = project
    if group: payload["group"] = group
    if version: payload["version"] = version

    data = json.dumps(payload).encode("utf-8")
    url = BASE_URL.rstrip("/") + "/rest/v1/group/name/job/name/run"
    auth = base64.b64encode(f"{USER}:{PASSWORD}".encode()).decode()
    req = urllib.request.Request(url, data=data, headers={
        "Content-Type": "application/json",
        "Authorization": f"Basic {auth}",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            body = r.read().decode("utf-8", errors="ignore")
            return {"status": r.status, "body": body[:500]}
    except Exception as e:
        return {"status": "error", "error": str(e)}

def lambda_handler(event, context):
    job_name = (event or {}).get("job_name") or "J_ORCH_Load_Deposits"
    project = (event or {}).get("project")
    group = (event or {}).get("group")
    version = (event or {}).get("version")
    return call_matillion(job_name, project, group, version)

