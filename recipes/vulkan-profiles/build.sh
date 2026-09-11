#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja -DBUILD_TESTS=OFF -DVULKAN_HEADERS_INSTALL_DIR=${PREFIX} .. 

cmake --build . --config Release
cmake --build . --config Release --target install
