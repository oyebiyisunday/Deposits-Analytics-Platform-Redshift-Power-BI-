import argparse, os
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score
import joblib

def parse_args():
    ap = argparse.ArgumentParser()
    ap.add_argument('--train', type=str, default=os.environ.get('SM_CHANNEL_TRAIN'))
    ap.add_argument('--model-dir', type=str, default=os.environ.get('SM_MODEL_DIR','/opt/ml/model'))
    return ap.parse_args()

def load_df(path):
    # Expect CSV/Parquet; fallback to CSV
    files = []
    for root, _, fns in os.walk(path):
        for fn in fns:
            if fn.endswith(('.csv','.parquet')):
                files.append(os.path.join(root, fn))
    dfs = []
    for f in files[:10]:  # sample
        if f.endswith('.parquet'):
            dfs.append(pd.read_parquet(f))
        else:
            dfs.append(pd.read_csv(f))
    return pd.concat(dfs, ignore_index=True) if dfs else pd.DataFrame()

def main():
    args = parse_args()
    df = load_df(args.train)
    if df.empty:
        raise SystemExit('No training data found')
    # Simple binary target from txn_type
    df['label'] = (df.get('txn_type','') == 'deposit').astype(int)
    X = df.select_dtypes(include=['number']).fillna(0)
    y = df['label']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    clf = LogisticRegression(max_iter=200)
    clf.fit(X_train, y_train)
    preds = clf.predict_proba(X_test)[:,1]
    auc = roc_auc_score(y_test, preds)
    os.makedirs(args.model_dir, exist_ok=True)
    joblib.dump(clf, os.path.join(args.model_dir, 'model.joblib'))
    with open(os.path.join(args.model_dir, 'metrics.txt'), 'w') as f:
        f.write(f"AUC={auc}\n")

if __name__ == '__main__':
    main()

