#!/bin/bash
set -euo pipefail
# Recipe files are not copied into $SRC_DIR, so reference the helper via
# $RECIPE_DIR. It copies the downloaded data/ tree (in $SRC_DIR) into
# $SP_DIR/satkit_data/data.
"$PYTHON" "$RECIPE_DIR/build_data.py"
