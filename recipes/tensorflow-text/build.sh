#!/bin/bash

set -exuo pipefail

export HERMETIC_PYTHON_VERSION=$(${PYTHON} -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

WHEEL_DIR=${PWD}/wheel_dir
mkdir -p ${WHEEL_DIR}
bazel build --experimental_repo_remote_exec oss_scripts/pip_package:build_pip_package
bazel-bin/oss_scripts/pip_package/build_pip_package ${WHEEL_DIR}
${PYTHON} -m pip install --no-deps ${WHEEL_DIR}/*.whl
bazel clean
