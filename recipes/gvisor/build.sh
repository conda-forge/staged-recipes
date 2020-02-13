#!/usr/bin/env bash

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"
export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++


bazel build --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 runsc