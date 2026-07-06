#!/usr/bin/env bash
set -euxo pipefail

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# Upstream incorrectly lists pybind11 as a runtime Requires-Dist; it is
# build-time only. Strip it so `pip check` matches real runtime deps.
python - <<'PY'
from pathlib import Path
import sysconfig

candidates = []
purelib = Path(sysconfig.get_paths()["purelib"])
platlib = Path(sysconfig.get_paths()["platlib"])
for base in {purelib, platlib}:
    candidates.extend(base.glob("pyflowy-*.dist-info/METADATA"))

if not candidates:
    raise SystemExit(f"pyflowy METADATA not found under {purelib} / {platlib}")

for meta in candidates:
    lines = meta.read_text(encoding="utf-8").splitlines(True)
    kept = [ln for ln in lines if not ln.lower().startswith("requires-dist: pybind11")]
    if kept == lines:
        raise SystemExit(f"no pybind11 Requires-Dist line in {meta}")
    meta.write_text("".join(kept), encoding="utf-8")
    print(f"stripped pybind11 Requires-Dist from {meta}")
PY
