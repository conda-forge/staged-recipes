#!/bin/bash
# Copyright 2023 Keegan Dent.
# SPDX-License-Identifier: GPL-3.0-only

mkdir build && cd build

# Configure step
cmake ${CMAKE_ARGS} .. \
    -G "Ninja" \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \

# Build step
ninja install