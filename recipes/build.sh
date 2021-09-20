#!/bin/bash

set -euxo pipefail

sed -i "s:\${BUILD_PREFIX}:${BUILD_PREFIX}:" protobuf.BUILD

source gen-bazel-toolchain

pushd compiler
bazel build --logging=6 --subcommands --verbose_failures --crosstool_top=//bazel_toolchain:toolchain --cpu ${TARGET_CPU} grpc_java_plugin
popd
mkdir -p $PREFIX/bin
cp bazel-bin/compiler/grpc_java_plugin $PREFIX/bin