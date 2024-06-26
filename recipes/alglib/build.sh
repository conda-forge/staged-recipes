#!/usr/bin/env bash

mkdir build
cd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -G Ninja ..
cmake --build .
cmake --install .
