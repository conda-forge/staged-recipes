#!/bin/bash

set -e
set -x

sed -i '20i include_directories("include", "${CMAKE_INSTALL_PREFIX}/include", "${CMAKE_INSTALL_PREFIX}/include/shrinkwrap", "${CMAKE_INSTALL_PREFIX}/include/htslib")' CMakeLists.txt

mkdir build-api
cd build-api
cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-static-libstdc++" \
  -DUSE_CXX3_ABI=ON \
  ${SRC_DIR}

make -j${CPU_COUNT} savvy
make install
cd ..

mkdir build-cli
cd build-cli
cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc -static-libstdc++" \
  ${SRC_DIR}

make -j${CPU_COUNT} sav
make -j${CPU_COUNT} manuals
make install
cd ..
