#!/usr/bin/env bash
set -euxo pipefail

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# Upstream incorrectly lists pybind11 as a runtime Requires-Dist; it is
# build-time only. Strip it so `pip check` matches real runtime deps.
# Use conda-forge SP_DIR (host site-packages), not sysconfig which can
# resolve to the build env under cross/compile isolation.
python - <<'PY'
from pathlib import Path
import os

sp = Path(os.environ["SP_DIR"])
prefix = Path(os.environ["PREFIX"])
candidates = list(sp.glob("pyflowy-*.dist-info/METADATA"))
if not candidates:
    # Fall back: recursive search under PREFIX site-packages trees.
    candidates = list(prefix.glob("**/pyflowy-*.dist-info/METADATA"))
if not candidates:
    raise SystemExit(f"pyflowy METADATA not found; SP_DIR={sp} PREFIX={prefix}")

for meta in candidates:
    lines = meta.read_text(encoding="utf-8").splitlines(True)
    kept = [
        ln
        for ln in lines
        if not ln.lower().startswith("requires-dist: pybind11")
    ]
    if kept == lines:
        raise SystemExit(f"no pybind11 Requires-Dist line in {meta}")
    meta.write_text("".join(kept), encoding="utf-8")
    print(f"stripped pybind11 Requires-Dist from {meta}")
PY
