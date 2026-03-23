#!/bin/bash

set -euxo pipefail

pushd tests

# It seems that during rattler-build's activation the header includes are erroneously point NOT to PREFIX.
export CFLAGS="${CFLAGS//${CONDA_PREFIX}/${PREFIX}}"
export CPPFLAGS="${CXXFLAGS//${CONDA_PREFIX}/${PREFIX}}"
export CXXFLAGS="${CXXFLAGS//${CONDA_PREFIX}/${PREFIX}}"

source gen-bazel-toolchain

mkdir -p ./third_party/systemlibs
cp -ap "${PREFIX}/share/bazel/systemlibs/absl" third_party/systemlibs/
export ABSEIL_VERSION="$(conda list -p "${PREFIX}" libabseil --fields version | awk '!/^#/ && NF { print $1; exit }')"
sed -i "s:ABSEIL_VERSION:${ABSEIL_VERSION}:" MODULE.bazel

bazel build \
  --subcommands \
  --logging=6 \
  --verbose_failures \
  --platforms=//bazel_toolchain:target_platform \
  --host_platform=//bazel_toolchain:build_platform \
  --extra_toolchains=//bazel_toolchain:cc_cf_toolchain \
  --extra_toolchains=//bazel_toolchain:cc_cf_host_toolchain \
  //:smoke_test
./bazel-bin/smoke_test
bazel clean --expunge
