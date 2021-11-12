#!/bin/sh

set -euo pipefail

CONDA_PREFIX="${PREFIX}" cmake -S "${SRC_DIR}" -B build
cmake --build build -- -j${CPU_COUNT}
cmake --install build --prefix ${SP_DIR}
