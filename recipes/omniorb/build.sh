#!/bin/bash

export CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++17/-std=c++14/g")

mkdir build
autoconf
cd build
../configure --prefix="${PREFIX}" \
             --with-openssl \
             --with-omniORB-config="${PREFIX}/etc/omniORB.cfg" \
             --with-omniNames-logdir="${PREFIX}/var"
make -j$CPU_COUNT
make install
