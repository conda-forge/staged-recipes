#!/usr/bin/env bash

# exit when any command fails
set -e
# print all commands
set -x

old_path="${PATH}"
export PATH="${PREFIX}/bin:${PATH}"

if [ "$(uname)" == Darwin ]; then
  export GRASS_PYTHON="${PREFIX}/bin/pythonw"
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
  export CFLAGS="${CFLAGS} -DGL_SILENCE_DEPRECATION"
else
  export GRASS_PYTHON="${PREFIX}/bin/python3"
  export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

CONFIGURE_FLAGS="\
  --prefix=${PREFIX} \
  --host=${HOST} \
  --with-cxx \
  --with-libs=${PREFIX}/lib \
  --with-includes=${PREFIX}/include \
  --with-freetype \
  --with-freetype-includes=${PREFIX}/include/freetype2 \
  --with-freetype-libs=${PREFIX}/lib \
  --with-gdal=${PREFIX}/bin/gdal-config \
  --with-proj-includes=${PREFIX}/include \
  --with-proj-libs=${PREFIX}/lib \
  --with-proj-share=${PREFIX}/share/proj \
  --with-postgres \
  --with-postgres-includes=${PREFIX}/include \
  --with-postgres-libs=${PREFIX}/lib \
  --with-geos=${PREFIX}/bin/geos-config \
  --with-libpng=${PREFIX}/bin/libpng-config \
  --with-tiff-includes=${PREFIX}/include \
  --with-tiff-libs=${PREFIX}/lib \
  --without-mysql \
  --with-sqlite \
  --with-sqlite-libs=${PREFIX}/lib \
  --with-sqlite-includes=${PREFIX}/include \
  --with-fftw-includes=${PREFIX}/include \
  --with-fftw-libs=${PREFIX}/lib \
  --with-lapack
  --with-lapack-includes=${PREFIX}/include \
  --with-lapack-libs=${PREFIX}/lib \
  --with-blas \
  --with-blas-libs=${PREFIX}/lib \
  --with-blas-includes=${PREFIX}/include \
  --with-cairo \
  --with-cairo-includes=${PREFIX}/include/cairo \
  --with-cairo-libs=${PREFIX}/lib \
  --with-cairo-ldflags=-lcairo \
  --with-zstd \
  --with-zstd-libs=${PREFIX}/lib \
  --with-zstd-includes=${PREFIX}/include \
  --with-pdal=${PREFIX}/bin/pdal-config \
  --with-bzlib \
  --with-bzlib-libs=${PREFIX}/lib \
  --with-bzlib-includes=${PREFIX}/include \
  --with-readline \
"

if [ "$(uname)" == Darwin ]; then
  CONFIGURE_FLAGS="\
    ${CONFIGURE_FLAGS} \
    --without-opengl \
    --with-opengl=aqua \
    --without-x \
    --with-macosx-sdk=${CONDA_BUILD_SYSROOT} \
    "
else
  CONFIGURE_FLAGS="\
    $CONFIGURE_FLAGS \
    --with-opengl \
    "
fi

(bash configure $CONFIGURE_FLAGS) || (cat config.log; false)

make -j"${CPU_COUNT}"

export PATH="${old_path}"
