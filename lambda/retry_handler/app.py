import os, json, time, boto3

LAMBDA = boto3.client("lambda")
SNS = boto3.client("sns")

MAX_RETRIES = int(os.environ.get("MAX_RETRIES", "3"))
RETRY_DELAY_BASE = int(os.environ.get("RETRY_DELAY_BASE", "60"))
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
TARGET_FUNCTION = os.environ.get("TARGET_FUNCTION")  # optional explicit target

def publish(msg):
    if SNS_TOPIC_ARN:
        try:
            SNS.publish(TopicArn=SNS_TOPIC_ARN, Message=json.dumps(msg) )
        except Exception:
            pass

def invoke_target(payload: dict):
    fn = TARGET_FUNCTION or os.environ.get("AWS_LAMBDA_FUNCTION_NAME", "")
    # If explicit target is not provided, default to matillion trigger discovered via env
    if not TARGET_FUNCTION:
        # Allow provisioning-time environment to set MATILLION trigger name
        fn = os.environ.get("MATILLION_TRIGGER_FN", fn)
    if not fn:
        return {"status": "skipped", "reason": "no_target"}
    resp = LAMBDA.invoke(FunctionName=fn, InvocationType="RequestResponse", Payload=json.dumps(payload).encode("utf-8"))
    body = resp.get("Payload")
    text = body.read().decode("utf-8") if body else ""
    return {"statusCode": resp.get("StatusCode"), "body": text[:500]}

def lambda_handler(event, context):
    payload = event.get("payload") if isinstance(event, dict) else None
    if not isinstance(payload, dict):
        payload = {"job_name": "J_ORCH_Load_Deposits"}

    for attempt in range(1, MAX_RETRIES + 1):
        result = invoke_target(payload)
        ok = isinstance(result.get("statusCode"), int) and result["statusCode"] < 400
        if ok:
            return {"status": "ok", "attempt": attempt, "result": result}
        delay = RETRY_DELAY_BASE * attempt
        publish({"event": "retry", "attempt": attempt, "delay": delay, "result": result})
        time.sleep(delay)

    publish({"event": "failed_after_retries", "max_retries": MAX_RETRIES})
    raise RuntimeError("Target invocation failed after retries")

