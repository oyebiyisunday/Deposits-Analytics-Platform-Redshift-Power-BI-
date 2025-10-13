import os, json, boto3, gzip
from urllib.parse import unquote_plus
s3=boto3.client('s3'); sns=boto3.client('sns')
EXPECTED={
 'sqlserver/accounts':['account_id','customer_id','branch_id','account_open_dt','account_type','currency_code','current_balance','status'],
 'sqlserver/transactions':['txn_id','account_id','txn_ts','amount','txn_type','currency_code','channel'],
 'files/branch_targets':['branch_id','target_month','deposits_target']
}
def read_head(bucket,key):
    obj=s3.get_object(Bucket=bucket,Key=key); body=obj['Body'].read()
    if key.endswith('.gz'): body=gzip.decompress(body)
    text=body.decode('utf-8',errors='ignore'); return [h.strip() for h in text.splitlines()[0].split(',')]
def lambda_handler(event, context):
    alerts=os.environ.get('ALERTS_TOPIC_ARN')
    for rec in event.get('Records',[]):
        b=rec['s3']['bucket']['name']; k=unquote_plus(rec['s3']['object']['key'])
        ds='/'.join(k.split('/')[:2]); 
        if ds not in EXPECTED: continue
        if read_head(b,k)!=EXPECTED[ds]:
            msg={"bucket":b,"key":k,"reason":"Schema header mismatch"}
            if alerts: sns.publish(TopicArn=alerts,Message=json.dumps(msg),Subject="ETL Schema Validation Failed")
            raise ValueError(f"Header mismatch for {k}")
    return {"status":"ok"}