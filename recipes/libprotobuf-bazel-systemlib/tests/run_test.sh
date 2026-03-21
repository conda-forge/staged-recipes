#!/bin/bash

set -euxo pipefail

pushd tests

export CFLAGS="${CFLAGS//${CONDA_PREFIX}/${PREFIX}}"
export CPPFLAGS="${CPPFLAGS//${CONDA_PREFIX}/${PREFIX}}"
export CXXFLAGS="${CXXFLAGS//${CONDA_PREFIX}/${PREFIX}}"
export ABSEIL_VERSION="$(conda list -p "${PREFIX}" libabseil --fields version | awk '!/^#/ && NF { print $1; exit }')"
export PROTOC_VERSION=$(conda list -p "${PREFIX}" libprotobuf --fields version | awk '!/^#/ && NF { print $1; exit }' | sed -E 's/^[0-9]+\.([0-9]+\.[0-9]+)$/\1/')

source gen-bazel-toolchain

mkdir -p third_party/systemlibs
cp -ap "${PREFIX}/share/bazel/systemlibs/protobuf" third_party/systemlibs/
cp -ap "${PREFIX}/share/bazel/protobuf/bazel" third_party/systemlibs/protobuf/
sed -i "s:PROTOC_VERSION:${PROTOC_VERSION}:" \
    third_party/systemlibs/protobuf/MODULE.bazel \
    MODULE.bazel
sed -i "s:ABSEIL_VERSION:${ABSEIL_VERSION}:" third_party/systemlibs/protobuf/MODULE.bazel

bazel build \
  --subcommands \
  --logging=6 \
  --verbose_failures \
  --define=PROTOC_PREFIX=${PREFIX} \
  --define=PROTOBUF_INCLUDE_PATH=${PREFIX}/include \
  --platforms=//bazel_toolchain:target_platform \
  --host_platform=//bazel_toolchain:build_platform \
  --extra_toolchains=//bazel_toolchain:cc_cf_toolchain \
  --extra_toolchains=//bazel_toolchain:cc_cf_host_toolchain \
  --@com_google_protobuf//bazel/toolchains:allow_nonstandard_protoc \
  --extra_toolchains=@com_google_protobuf//bazel/private/toolchains:cc_source_toolchain \
  --extra_toolchains=@com_google_protobuf//bazel/private/toolchains:protoc_sources_toolchain \
  //:smoke_test
./bazel-bin/smoke_test
bazel clean --expunge
