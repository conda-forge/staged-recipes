#!/bin/sh

if test `uname` = "Darwin"
then
  SO_EXT='.dylib'
else
  SO_EXT='.so'
fi

mkdir -p build && cd build

cmake \
  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBLAS_LIBRARIES=${PREFIX}/lib/libopenblas${SO_EXT} \
  -DBUILD_EXAMPLES=ON \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
  -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_CXX_FLAGS="-std=c++11" \
  ..

make install
rm -r ${PREFIX}/bin/examples
./c-simple-cylinder 1000 D
