#!/bin/sh

if test `uname` = "Darwin"
then
  SO_EXT='.dylib'
else
  SO_EXT='.so'
fi


mkdir -p build && cd build

for shared_libs in OFF ON
do
  cmake \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DBUILD_SHARED_LIBS=${shared_libs} \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    ..

  make -j${CPU_COUNT}
done
cp lib/libarpack${SO_EXT} libarpack.a ${PREFIX}/lib
DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib make check -j${CPU_COUNT}
