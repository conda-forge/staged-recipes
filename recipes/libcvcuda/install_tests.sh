#!/bin/bash
set -euo pipefail
cmake --install "${SRC_DIR}/build" --component tests --prefix "${PREFIX}"
mv "${PREFIX}/bin/run_tests.sh" "${PREFIX}/bin/run_libcvcuda_tests.sh"
