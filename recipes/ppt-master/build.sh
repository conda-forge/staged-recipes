#!/bin/bash
set -euo pipefail
export PYTHONIOENCODING=utf-8
"${PYTHON}" "${RECIPE_DIR}/build_recipe.py"
