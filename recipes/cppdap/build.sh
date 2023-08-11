#!/usr/bin/env bash

# https://github.com/google/cppdap
# https://fuchsia.googlesource.com/third_party/github.com/google/cppdap/
# Uses
# - https://anaconda.org/conda-forge/nlohmann_json

echo cmake-args: "${CMAKE_ARGS}"

cmake \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    "$SRC_DIR" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_TESTING=OFF \
    -DJSON_MultipleHeaders=ON \
    "${CMAKE_ARGS}"

make install

