#!/bin/bash

# Remove vendored deps we want to ensure we don't use or use c-f versions of
rm -rf Libraries/{fast_float,googletest,libressl,libzip,zlib}
rm -rf submodules/{AutomaticComponentToolkit,fast_float,googletest,libzip,zlib}

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DUSE_INCLUDED_ZLIB=NO \
    -DUSE_INCLUDED_LIBZIP=NO \
    -DUSE_INCLUDED_SSL=NO \
    ${CMAKE_ARGS} \
    ..

cmake --build .
cmake --build . --target=install
