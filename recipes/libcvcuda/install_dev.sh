#!/bin/bash
set -euo pipefail
cmake --install "${SRC_DIR}/build" --component dev --prefix "${PREFIX}"
