#!/bin/bash
set -xeo pipefail
cp ${RECIPE_DIR}/setup.py .
python -m pip install . -vv
