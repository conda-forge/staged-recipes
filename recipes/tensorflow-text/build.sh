#!/bin/bash

set -exuo pipefail

WHEEL_DIR=${PWD}/wheel_dir
mkdir -p ${WHEEL_DIR}
bazel build ./oss_scripts/pip_package:build_pip_package
bazel-bin/text/oss_scripts/pip_package/build_pip_package ${WHEEL_DIR}
${PYTHON} -m pip install --no-deps ${WHEEL_DIR}/*.whl
bazel clean
