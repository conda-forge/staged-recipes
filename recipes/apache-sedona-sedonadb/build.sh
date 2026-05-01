#!/usr/bin/env bash
set -euxo pipefail

# Strip the C extension declaration from pyproject.toml so the resulting
# wheel is pure Python (noarch). The geomserde_speedup extension only
# accelerates the PySpark serialization codepath, which is unused in this
# lightweight build (no pyspark dep). The Python fallback in
# sedona/spark/utils/geometry_serde.py handles the case where the
# compiled module is absent.
python - <<'PY'
import pathlib
import re

path = pathlib.Path("pyproject.toml")
text = path.read_text()
pattern = re.compile(
    r"\n*(?:#[^\n]*\n)*\[\[tool\.setuptools\.ext-modules\]\][\s\S]*?(?=\n\[|\Z)"
)
new_text, n = pattern.subn("\n", text)
if n != 1:
    raise SystemExit("Failed to strip ext-modules block from pyproject.toml")
path.write_text(new_text)
PY

"$PYTHON" -m pip install . -vv --no-deps --no-build-isolation
