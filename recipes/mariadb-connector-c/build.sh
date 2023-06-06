#!/bin/bash

mkdir build

cd build

cmake ../mariadb-connector-c-3.3.5 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

cmake --build ../build --config Release

make -j{CPU_COUNT}

make install
