import os, json, joblib, pandas as pd

"""
Example batch scoring script: loads a saved model and scores a dataset,
writing predictions to a CSV in the curated bucket.
Env: MODEL_S3_URI, INPUT_S3_URI, OUTPUT_S3_URI (s3 URIs), AWS creds configured.
"""

def main():
    from sagemaker.s3 import S3Downloader, S3Uploader
    model_dir = "/tmp/model"
    data_dir = "/tmp/input"
    out_dir = "/tmp/output"
    os.makedirs(model_dir, exist_ok=True)
    os.makedirs(data_dir, exist_ok=True)
    os.makedirs(out_dir, exist_ok=True)
    S3Downloader.download(os.environ['MODEL_S3_URI'], model_dir)
    S3Downloader.download(os.environ['INPUT_S3_URI'], data_dir)
    # Load first model artifact
    model_path = None
    for root, _, files in os.walk(model_dir):
        for f in files:
            if f.endswith('.joblib'):
                model_path = os.path.join(root, f)
                break
    if not model_path:
        raise SystemExit('No model artifact found')
    model = joblib.load(model_path)
    # Load and score
    frames = []
    for root, _, files in os.walk(data_dir):
        for f in files:
            if f.endswith(('.csv','.parquet')):
                p = os.path.join(root, f)
                frames.append(pd.read_parquet(p) if p.endswith('.parquet') else pd.read_csv(p))
    df = pd.concat(frames, ignore_index=True)
    X = df.select_dtypes(include=['number']).fillna(0)
    df['score'] = model.predict_proba(X)[:,1]
    out_path = os.path.join(out_dir, 'scores.csv')
    df[['score']].to_csv(out_path, index=False)
    S3Uploader.upload(out_path, os.environ['OUTPUT_S3_URI'])
    print(json.dumps({"rows": len(df)}, indent=2))

if __name__ == '__main__':
    main()

