import argparse, pathlib

def render_template(src: str, dst: str, mapping: dict):
    text = pathlib.Path(src).read_text(encoding="utf-8")
    for k, v in mapping.items():
        text = text.replace(f"{{{{{k}}}}}", str(v))
    out = pathlib.Path(dst)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8")
    print(f"Rendered {src} -> {dst}")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", required=True)
    ap.add_argument("--bucket-suffix", required=True)
    ap.add_argument("--aws-account-id", required=True)
    ap.add_argument("--redshift-role-name", required=True)
    ap.add_argument("--manifest-name", default="2025-10-01")
    ap.add_argument("--out-dir", default="dist/sql")
    args = ap.parse_args()

    mapping = {
        "project": args.project,
        "bucket_suffix": args.bucket_suffix,
        "aws_account_id": args.aws_account_id,
        "redshift_role_name": args.redshift_role_name,
        "manifest_name": args.manifest_name,
    }

    render_template(
        "sql/templates/05_copy_commands.sql.tmpl",
        f"{args.out_dir}/05_copy_commands.sql",
        mapping,
    )
    render_template(
        "sql/templates/copy_with_manifest.sql.tmpl",
        f"{args.out_dir}/copy_with_manifest.sql",
        mapping,
    )
    render_template(
        "sql/templates/unload_curated_parquet.sql.tmpl",
        f"{args.out_dir}/unload_curated_parquet.sql",
        mapping,
    )

if __name__ == "__main__":
    main()
