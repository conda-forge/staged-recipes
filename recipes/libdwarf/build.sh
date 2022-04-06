#!/bin/bash

set -xe 
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig

# we patch the autotools files to add extra options for testing
# go ahead and regen
autoreconf --install --force

mkdir build
cd build

#cmake -DCMAKE_BUILD_TYPE=Release \
#      -DCMAKE_INSTALL_MANDIR=man \
#      -DBUILD_NON_SHARED=FALSE \
#      -DBUILD_SHARED=TRUE \
#      -DDO_TESTING=TRUE \
#      $CMAKE_ARGS ..
#cmake  --build . -j${CPU_COUNT}
#ctest -R self
# README.cmake says install isn't working correctly yet
# doesn't include pkgconfig file and installs into weird places

../configure --enable-shared \
          --disable-static \
	  --prefix=$PREFIX \
	  --mandir=$PREFIX/man

make -j${CPU_COUNT}
make check
make install
mv $PREFIX/include/libdwarf-*/libdwarf.h $PREFIX/include
# leave dwarf.h inside include/libdwarf-0 because elfutils also has a vendored dwarf.h
# but we want libdwarf.h to not be versioned

cd ..
# cleanup src directory because tests will copy it in for running on
# installed artifacts
rm -rf build
