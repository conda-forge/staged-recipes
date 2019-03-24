#!/bin/bash

export CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++17/-std=c++14/g")

mkdir -p ${PREFIX}/var/omniNames-logs
touch ${PREFIX}/var/omniNames-logs/.mkdir
mkdir -p ${PREFIX}/etc/omniORB-config
touch ${PREFIX}/etc/omniORB-config/.mkdir

mkdir build
autoconf
cd build
../configure --prefix="${PREFIX}" \
             --with-openssl \
             --with-omniORB-config="${PREFIX}/etc/omniORB-config/omniORB.cfg" \
             --with-omniNames-logdir="${PREFIX}/var/omniNames-logs"
make -j$CPU_COUNT
make install
