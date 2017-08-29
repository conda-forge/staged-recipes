#!/bin/bash

[[ -d build ]] || mkdir build
cd build/

# have to set CMAKE_INSTALL_LIBDIR otherwise it ends up under 'x86_64-linux-gnu'

cmake \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -D CMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    ..

make -j$CPU_COUNT
# No "make check" available
make install

# we are fixing the paths to dynamic library files inside library 
# because something in make install is doubling up the
# path to the library files.  Anyone who knows how to solve that
# problem is free to contact the maintainers.
# See the GMT feedstock for similar problem

if [[ "$(uname)" == "Darwin" ]];then
    install_name_tool -id $PREFIX/lib/libqt5keychain.0.8.0.dylib $PREFIX/lib/libqt5keychain.0.8.0.dylib
fi
