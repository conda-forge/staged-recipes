#! /usr/bin/env bash
export BUILD_TYPE=Release
mkdir build && cd build

export ENABLE_GRIB=ON

export LDFLAGS="$LDFLAGS -lnetcdff -leccodes_f90"

if [[ "$target_platform" == osx-* ]]; then
  export FFLAGS="-isysroot $CONDA_BUILD_SYSROOT $FFLAGS"
  export ENABLE_GRIB=ON
fi

cmake \
  ${CMAKE_ARGS} \
  -D CMAKE_INSTALL_PREFIX=$PREFIX \
  -D CMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -D GRIB=${ENABLE_GRIB} \
  -D NCDF=ON \
  -D OPENGL=OFF \
  $SRC_DIR


cmake --build . --target install --config Release
