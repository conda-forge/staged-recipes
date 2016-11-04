#!/bin/sh

if test `uname` = "Darwin"
then
  SHLIB_EXT='.dylib'
else
  SHLIB_EXT='.so'
fi

mkdir -p build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DBUILD_SWIG_JAVA=OFF \
  -DBUILD_TESTS=OFF \
  ..

make -j${CPU_COUNT}

# no install rule
cp -v export/libfmippex${SHLIB_EXT} ${PREFIX}/lib
cp -v import/libfmippim${SHLIB_EXT} ${PREFIX}/lib
cp -v import/swig/_fmippim.so ${SP_DIR}
cp -v import/swig/fmippim.py ${SP_DIR}
