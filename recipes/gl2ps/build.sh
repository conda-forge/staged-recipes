#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/

mkdir -p build
cd build

cmake -LAH \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=${CMAKE_PLATFORM_FLAGS[@]+"${CMAKE_PLATFORM_FLAGS[@]}"} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ../source

cmake --build . -j${CPU_COUNT}
cmake --build . --target install

./gl2psTest
./gl2psTestSimple
