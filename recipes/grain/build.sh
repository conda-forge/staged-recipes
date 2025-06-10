#!/bin/bash

mkdir -p /tmp/grain
cp -r . /tmp/grain

set -xe
export PYTHON_VERSION=$(${PYTHON} -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')")
export PYTHON_MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f1)
export PYTHON_MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f2)
export BAZEL_VERSION="7.1.1"
export OUTPUT_DIR="/tmp/grain"
export SOURCE_DIR="/tmp/grain"
export RUN_TESTS="true"
. "/tmp/grain/oss/runner_common.sh"
build_and_test_grain

${PYTHON} -m pip install /tmp/grain/all_dist/grain-*.whl
