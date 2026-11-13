#!/bin/bash
set -euxo pipefail

cmake -G Ninja -B _build -S "${RECIPE_DIR}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DMCAP_SOURCE_DIR="${SRC_DIR}/cpp/mcap" \
  -DMCAP_VERSION="${PKG_VERSION}"
cmake --install _build
