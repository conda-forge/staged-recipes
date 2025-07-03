#!/bin/bash

# mkdir -p ./tmp/grain
# cp -r . ./tmp/grain

set -xe
export PYTHON_VERSION=$(${PYTHON} -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')")
export PYTHON_MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f1)
export PYTHON_MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f2)
export BAZEL_VERSION="7.2.1"
export OUTPUT_DIR="."
export SOURCE_DIR="."
export RUN_TESTS="true"
. "./grain/oss/runner_common.sh"

#build_and_test_grain
setup_env_vars_py "$PYTHON_MAJOR_VERSION" "$PYTHON_MINOR_VERSION"
sh "${SOURCE_DIR}"'/grain/oss/build_whl.sh'

${PYTHON} -m pip install ./all_dist/grain-*.whl
