#!/usr/bin/env bash

set -euxo pipefail

"${PYTHON}" setup.py build_ext --inplace
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
