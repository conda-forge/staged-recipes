#!/usr/bin/env bash

set -ex

mv $PREFIX/lib/pkgconfig/{lapack,blas}.pc $SRC_DIR


ls $PREFIX/lib/pkgconfig

echo "Checking include path..."
ls -l ${PREFIX}/include

echo "Checking library path..."
ls -l ${PREFIX}/lib
cat ${PREFIX}/include/omp.h


if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  MESON_ARGS=${MESON_ARGS:---prefix=${PREFIX} --libdir=lib}
else
  cat > pkgconfig.ini <<EOF
[binaries]
pkgconfig = '${BUILD_PREFIX}/bin/pkg-config'
EOF
  MESON_ARGS="${MESON_ARGS:---prefix=${PREFIX} --libdir=lib} --cross-file pkgconfig.ini"
fi


meson setup _build \
  ${MESON_ARGS} \
  --includedir=include \
  --buildtype=release \
  --warnlevel=0 \
  --default-library=shared \
  -Dlapack=openblas

meson compile -C _build

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  meson test -C _build --no-rebuild --print-errorlogs --suite unit -t 20
fi

meson install -C _build --no-rebuild


mv $SRC_DIR/{lapack,blas}.pc $PREFIX/lib/pkgconfig
