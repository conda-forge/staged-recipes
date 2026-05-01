#!/usr/bin/env bash
set -euxo pipefail

# Strip the C extension from pyproject.toml so the wheel is pure-Python
# (noarch). See strip_ext_modules.py for rationale.
"$PYTHON" "$RECIPE_DIR/strip_ext_modules.py"

"$PYTHON" -m pip install . -vv --no-deps --no-build-isolation
