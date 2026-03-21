#!/bin/bash

set -euxo pipefail

mkdir -p ${PREFIX}/share/bazel/systemlibs
cp -ap ${RECIPE_DIR}/absl ${PREFIX}/share/bazel/systemlibs/
sed -i "s:ABSEIL_VERSION:${PKG_VERSION}:" ${PREFIX}/share/bazel/systemlibs/absl/MODULE.bazel
