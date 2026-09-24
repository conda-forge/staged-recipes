#!/usr/bin/env bash

set -ex

meson setup _build \
  ${MESON_ARGS:---prefix=${PREFIX} --libdir=lib} \
  --buildtype=release \
  --wrap-mode=nodownload \
  --pkg-config-path "${PREFIX}/lib/pkgconfig"

meson compile -C _build

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "0" ]]; then
  meson test -C _build \
    --no-rebuild \
    --print-errorlogs \
    --suite unit
fi

meson install -C _build --no-rebuild
