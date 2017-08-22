#!/bin/sh

mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DINSTALL_INCLUDE_DIR=${PREFIX}/include/hmat \
  -DBLAS_LIBRARIES=${PREFIX}/lib/libopenblas${SHLIB_EXT} \
  -DBUILD_EXAMPLES=ON \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
  -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_CXX_FLAGS="-std=c++11" \
  ..

make install -j${CPU_COUNT}
./c-simple-cylinder 1000 D
