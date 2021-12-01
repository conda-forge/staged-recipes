#!/bin/bash

set -ex

export PATH="$PWD:$PATH"
export CC=$(basename $CC)
export CXX=$(basename $CXX)
export LIBDIR=$PREFIX/lib
export INCLUDEDIR=$PREFIX/include

export BAZEL_OPT=""
if [[ "${target_platform}" == osx-* ]]; then
  export LDFLAGS="${LDFLAGS} -lz -framework CoreFoundation -Xlinker -undefined -Xlinker dynamic_lookup"
  # The feature deselection can be removed again with bazel 5.0
  # https://github.com/abseil/abseil-cpp/issues/848
  export BAZEL_OPT="${BAZEL_OPT} --features=-supports_dynamic_linker"
else
  export LDFLAGS="${LDFLAGS} -lrt"
fi
if [[ "${target_platform}" == "osx-arm64" ]]; then
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=11.0"
fi

sed -ie "s:\${SRC_DIR}:${SRC_DIR}:" third_party/repo.bzl

pushd cc
source gen-bazel-toolchain
bazel clean
bazel build --crosstool_top=//bazel_toolchain:toolchain --define=PROTOBUF_INCLUDE_PATH=${PREFIX}/include --cpu=${TARGET_CPU} ${BAZEL_OPT} ...