#!/bin/bash
set -xeuo pipefail

CORRECTNESS="${RECIPE_DIR}/python_bindings/correctness"
for TEST in `ls "$CORRECTNESS"`; do
    echo "Testing $TEST"
    "$PYTHON" "${CORRECTNESS}/${TEST}"
done
