import argparse, json, pathlib, re

SQL_DIRS = [
    pathlib.Path("sql"),
    pathlib.Path("sql/incremental"),
    pathlib.Path("sql/security"),
    pathlib.Path("sql/benchmarks"),
]

TABLE_RE = re.compile(r"\b(?:from|join|into)\s+([a-zA-Z0-9_\.]+)", re.IGNORECASE)
TARGET_RE = re.compile(r"\b(?:create\s+table|insert\s+into)\s+([a-zA-Z0-9_\.]+)", re.IGNORECASE)

def parse_sql(text: str):
    sources = set(m.group(1) for m in TABLE_RE.finditer(text))
    targets = set(m.group(1) for m in TARGET_RE.finditer(text))
    return sources, targets

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="dist/lineage.json")
    args = ap.parse_args()

    nodes = set()
    edges = set()
    files = []
    for d in SQL_DIRS:
        if not d.exists():
            continue
        for p in d.rglob("*.sql"):
            try:
                text = p.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                continue
            sources, targets = parse_sql(text)
            files.append(str(p))
            for t in targets:
                nodes.add(t)
            for s in sources:
                nodes.add(s)
            for t in targets:
                for s in sources:
                    edges.add((s, t))

    out = pathlib.Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    data = {
        "nodes": sorted(nodes),
        "edges": sorted([{"from": a, "to": b} for a, b in edges], key=lambda x: (x["from"], x["to"])) ,
        "scanned_files": files,
    }
    out.write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(f"Wrote lineage to {out}")

if __name__ == "__main__":
    main()

