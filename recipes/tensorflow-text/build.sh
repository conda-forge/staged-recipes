#!/bin/bash

set -exuo pipefail

export HERMETIC_PYTHON_VERSION=$(${PYTHON} -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

./oss_scripts/run_build.sh
${PYTHON} -m pip install --no-deps --no-build-isolation -vv tensorflow_text-*.whl
bazel clean
