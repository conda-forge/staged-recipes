#!/bin/bash

sed -i 's@set(CMAKE_CXX_FLAGS "-std=c++11")@@g' CMakeLists.txt
sed -i 's@set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-dev")@@g' CMakeLists.txt
sed -i 's@set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")@@g' CMakeLists.txt
sed -i 's@set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror=return-type")@@g' CMakeLists.txt

mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DROCM_ROOT=$PREFIX \
  ..

make VERBOSE=1 -j${CPU_COUNT}
make install
