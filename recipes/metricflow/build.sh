#!/usr/bin/env bash
set -euo pipefail

python "${RECIPE_DIR}/fix_symlinks.py"
python -m pip install . -vv --no-deps --no-build-isolation
