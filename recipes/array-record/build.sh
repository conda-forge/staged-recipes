#!/bin/bash

set -exuo pipefail

# source gen-bazel-toolchain

# export CROSSTOOL_TOP="//bazel_toolchain:toolchain"
export AUDITWHEEL_PLATFORM="manylinux2014_$(uname -m)"
export PYTHON_BIN="${PYTHON}"

./oss/build_whl.sh

${PYTHON} -m pip install -vv --no-deps --no-build-isolation /tmp/array_record/all_dist/*.whl
