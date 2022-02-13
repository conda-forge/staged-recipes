#!/bin/bash

set -euxo pipefail

source gen-bazel-toolchain

export LIBPROTOBUF_VERSION=$(conda list -p $PREFIX libprotobuf | grep -v '^#' | tr -s ' ' | cut -f 2 -d ' ')
export EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk"
sed -ie "s:LIBPROTOBUF_VERSION:${LIBPROTOBUF_VERSION}:" WORKSPACE
sed -ie "s:\${INSTALL_NAME_TOOL}:${INSTALL_NAME_TOOL:-install_name_tool}:" src/BUILD
sed -ie "s:\${PREFIX}:${PREFIX}:" src/BUILD
sed -ie "s:\${BUILD_PREFIX}:${BUILD_PREFIX}:" third_party/grpc/BUILD
sed -ie "s:\${BUILD_PREFIX}:${BUILD_PREFIX}:" third_party/systemlibs/protobuf.BUILD
sed -ie "s:\${BUILD_PREFIX}:${BUILD_PREFIX}:" third_party/ijar/BUILD

chmod +x bazel
pushd src/tools/singlejar
../../../bazel build --logging=6 --subcommands --verbose_failures --define=PROTOBUF_INCLUDE_PATH=${PREFIX}/include --crosstool_top=//bazel_toolchain:toolchain --cpu ${TARGET_CPU} singlejar singlejar_local
mkdir -p $PREFIX/bin
cp ../../../bazel-out/${TARGET_CPU}-fastbuild/bin/src/tools/singlejar/singlejar $PREFIX/bin
cp ../../../bazel-out/${TARGET_CPU}-fastbuild/bin/src/tools/singlejar/singlejar_local $PREFIX/bin
