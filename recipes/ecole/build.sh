#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset


cmake -B build -S "${SRC_DIR}" -D CMAKE_BUILD_TYPE=Release -D PYTHON_EXECUTABLE="${PYTHON}"
cmake --build build --parallel ${CPU_COUNT}
"${PYTHON}" -m pip install --no-deps build/python/
