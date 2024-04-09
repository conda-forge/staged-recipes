#!/usr/bin/env bash

cmake ${CMAKE_ARGS} -G Ninja -S "$SRC_DIR" -B build -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_EXAMPLES="OFF" -DBUILD_TESTS="OFF" 

ninja -C build install
