#! /usr/bin/env bash
export BUILD_TYPE=Release
mkdir build && cd build

if [[ "$target_platform" == osx-* ]]; then
  export FFLAGS="-isysroot $CONDA_BUILD_SYSROOT $FFLAGS"
fi

cmake \
  ${CMAKE_ARGS} \
  -D CMAKE_INSTALL_PREFIX=$PREFIX \
  -D CMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -D GRIB=ON \
  -D NCDF=ON \
  -D OPENGL=OFF \
  $SRC_DIR


#cmake --build . --target install --config Release
make 
make install