#!/usr/bin/env bash

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE=$PREFIX/bin/python \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DHEYOKA_PY_ENABLE_IPO=yes \
    ..

make -j${CPU_COUNT} VERBOSE=1

make install
