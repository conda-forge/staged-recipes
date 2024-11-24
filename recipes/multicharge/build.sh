#!/usr/bin/env bash

set -ex

mv $PREFIX/lib/pkgconfig/{lapack,blas}.pc $SRC_DIR

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  MESON_ARGS=${MESON_ARGS:---prefix=${PREFIX} --libdir=lib}
else
  cat > pkgconfig.ini <<EOF
[binaries]
pkgconfig = '$BUILD_PREFIX/bin/pkg-config'
EOF
  MESON_ARGS="${MESON_ARGS:---prefix=${PREFIX} --libdir=lib} --cross-file pkgconfig.ini"
fi

meson setup _build \
  ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Dlapack=custom \
  -Dcustom_libraries=lapack,blas

meson compile -C _build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  meson test -C _build --no-rebuild --print-errorlogs
fi
meson install -C _build --no-rebuild

mv $SRC_DIR/{lapack,blas}.pc $PREFIX/lib/pkgconfig
