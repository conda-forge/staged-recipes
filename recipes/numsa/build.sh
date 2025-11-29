#!/usr/bin/env bash

set -ex

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  MESON_ARGS=${MESON_ARGS:---prefix=${PREFIX} --libdir=lib}
else
  cat > pkgconfig.ini <<EOF
[binaries]
pkgconfig = '$BUILD_PREFIX/bin/pkg-config'
EOF
  MESON_ARGS="${MESON_ARGS:---prefix=${PREFIX} --libdir=lib} --cross-file pkgconfig.ini"
fi

if [[ "$target_platform" == "osx-64" ]]; then
  MESON_ARGS="${MESON_ARGS} -Dopenmp=false"
fi

meson setup _build \
  ${MESON_ARGS}

meson compile -C _build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  meson test -C _build --no-rebuild --print-errorlogs
fi
meson install -C _build --no-rebuild
