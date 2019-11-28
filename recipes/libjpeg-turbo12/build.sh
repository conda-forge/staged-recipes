#!/bin/bash

mkdir build_libjpeg && cd  build_libjpeg

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR="$PREFIX/lib" \
      -D CMAKE_BUILD_TYPE=Release \
      -D ENABLE_STATIC=1 \
      -D ENABLE_SHARED=1 \
      -D CMAKE_ASM_NASM_COMPILER=yasm \
      -D WITH_12BIT=1 \
      -D CMAKE_RELEASE_POSTFIX=12 \
      -D CMAKE_EXECUTABLE_SUFFIX=12 \
      -D CMAKE_INSTALL_INCLUDEDIR="$PREFIX/include/jpeg12" \
      -D CMAKE_INSTALL_DOCDIR="$PREFIX/share/doc/libjpeg-turbo12" \
      $SRC_DIR

make -j$CPU_COUNT
 # ctest
make install -j$CPU_COUNT

# We can remove this when we start using the new conda-build.
find $PREFIX -name '*.la' -delete

pushd $PREFIX/share/man/man1/

mv wrjpgcom.1 wrjpgcom12.1
mv djpeg.1 djpeg12.1
mv rdjpgcom.1 rdjpgcom12.1
mv jpegtran.1 jpegtran12.1
mv cjpeg.1 cjpeg12.1

popd

pushd $PREFIX/lib/pkgconfig/

cat libturbojpeg.pc | sed s/-lturbojpeg/-lturbojpeg12/g > libturbojpeg12.pc
cat libjpeg.pc | sed s/-ljpeg/-ljpeg12/g > libjpeg12.pc

rm libturbojpeg.pc libjpeg.pc

popd

