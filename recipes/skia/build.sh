#!/bin/bash
set -euxo pipefail

python "${RECIPE_DIR}/build_libskia.py"
