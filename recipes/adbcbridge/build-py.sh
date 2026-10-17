#!/bin/bash
set -euxo pipefail

# Do not bundle a copy of the library into the wheel: libadbcbridge already installed it
# to $PREFIX/lib, where adbcbridge.driver_path() looks. Pointing the build dir at a path
# that does not exist makes setup.py skip the bundling step.
export ADBCBRIDGE_BUILD_DIR="${SRC_DIR}/no-such-build-dir"
cd "${SRC_DIR}/python"
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
