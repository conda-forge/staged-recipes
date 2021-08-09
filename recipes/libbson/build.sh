#!/bin/sh

[[ -d build ]] || mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF \
      -DENABLE_MONGOC=OFF \
      -DENABLE_STATIC=DONT_INSTALL \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DBUILD_SHARED_LIBS=ON

cmake --build . --config Release
cmake --build . --config Release --target install

# Although static install is disabled, the correspondong cmake config files are still installed
rm -rf $PREFIX/lib/cmake/libbson-static-1.0
