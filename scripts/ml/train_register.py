import os, sagemaker
from sagemaker.inputs import TrainingInput
from sagemaker.sklearn.estimator import SKLearn

"""
Example training script using SageMaker SDK.
Assumes curated Parquet/CSV exists under s3://<project>-curated-<suffix>/ml/.
Trains a toy model and registers an artifact (sklearn) to the model registry (optional).
"""

def main():
    session = sagemaker.Session()
    role = os.environ.get("SAGEMAKER_ROLE_ARN")
    bucket = os.environ.get("CURATED_BUCKET")
    prefix = os.environ.get("TRAIN_PREFIX", "ml/fact_transactions/")

    script_path = os.path.join(os.path.dirname(__file__), "train_script.py")
    est = SKLearn(entry_point=script_path, role=role, instance_type="ml.m5.large", framework_version="1.3-1")
    est.fit({"train": TrainingInput(f"s3://{bucket}/{prefix}")})

if __name__ == "__main__":
    main()

