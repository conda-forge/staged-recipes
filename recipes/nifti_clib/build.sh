#!/bin/sh
mkdir ../build && cd ../build

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

cmake \
  "${CMAKE_PLATFORM_FLAGS[@]}" \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DUSE_CIFTI_CODE=ON \
  -DUSE_NIFTI2_CODE=ON \
  -DZLIB_LIBRARY=$PREFIX/lib/libz${SHLIB_EXT} \
  -DZLIB_INCLUDE_DIR=$PREFIX/include \
  $SRC_DIR

make install