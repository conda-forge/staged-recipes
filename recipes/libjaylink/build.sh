#!/usr/bin/env bash

set -euxo pipefail

pushd "${SRC_DIR}" || exit 1
  meson setup build-${PKG_NAME} \
    --prefix="${PREFIX}" \
    --buildtype=release \
    --default-library=shared \
    --strip \
    --backend=ninja
  meson compile -C build-${PKG_NAME}
  meson install -C build-${PKG_NAME}
popd || exit 1
