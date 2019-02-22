#!/bin/bash

export CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++17/-std=c++14/g")

mkdir build
autoconf
cd build
../configure PYTHON='which python'--prefix=$PREFIX --with-openssl
make -j$CPU_COUNT
make install
