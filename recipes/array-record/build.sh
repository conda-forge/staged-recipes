#!/bin/bash

set -exuo pipefail

# https://github.com/bazelbuild/bazel/issues/14355
# Remove or change when upgrading Bazel 5.4.0
rm -rf "${BUILD_PREFIX}/share/bazel/install/e57f3167855b9a43667af9e285ef5011" "${BUILD_PREFIX}/share/bazel/install/9082e60c79e20e02757c184b5b7ffaf0"

source gen-bazel-toolchain

export CROSSTOOL_TOP="//bazel_toolchain:toolchain"
if [ "${LINUX}" = "1" ]; then
    export AUDITWHEEL_PLATFORM="manylinux2014_$(uname -m)"
fi
export PYTHON_BIN="${PYTHON}"

./oss/build_whl.sh

${PYTHON} -m pip install -vv --no-deps --no-build-isolation /tmp/array_record/all_dist/*.whl
