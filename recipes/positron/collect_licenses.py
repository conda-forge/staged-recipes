"""Collect license files and declared npm licenses of everything bundled in the Positron app.

usage: collect_licenses.py APP_DIR OUT_DIR
"""
import sys
import os, re, shutil
app = sys.argv[1]
out = sys.argv[2]
for root, dirs, files in os.walk(app):
    for f in files:
        if re.match(r"(LICEN[CS]E|COPYING|NOTICE)", f, re.I):
            rel = os.path.relpath(os.path.join(root, f), app)
            dst = os.path.join(out, rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy2(os.path.join(root, f), dst)
# summary of the declared license of every bundled npm package (covers packages without a license file)
import json
rows = set()
for root, dirs, files in os.walk(app):
    if "package.json" in files and os.path.basename(os.path.dirname(root)) in ("node_modules",) or \
       "package.json" in files and os.path.basename(os.path.dirname(os.path.dirname(root))) == "node_modules":
        try:
            meta = json.load(open(os.path.join(root, "package.json")))
        except Exception:
            continue
        if meta.get("name") and meta.get("version"):
            lic = meta.get("license") or meta.get("licenses") or "UNKNOWN"
            rows.add(f"{meta['name']}@{meta['version']}\t{json.dumps(lic) if not isinstance(lic, str) else lic}")
os.makedirs(out, exist_ok=True)
with open(os.path.join(out, "npm-packages.tsv"), "w") as fh:
    fh.write("\n".join(sorted(rows)) + "\n")
