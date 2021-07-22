#!/bin/bash

set -euxo pipefail

mkdir -p $PREFIX/bin
cp ${RECIPE_DIR}/gen-bazel-toolchain $PREFIX/bin/
mkdir -p $PREFIX/share
cp -r ${RECIPE_DIR}/bazel_toolchain ${PREFIX}/share/
