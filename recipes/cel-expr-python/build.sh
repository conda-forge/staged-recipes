#!/bin/bash

set -euxo pipefail

source gen-bazel-toolchain

cat >> .bazelrc <<EOF

build --crosstool_top=//bazel_toolchain:toolchain
build --platforms=//bazel_toolchain:target_platform
build --host_platform=//bazel_toolchain:build_platform
build --extra_toolchains=//bazel_toolchain:cc_cf_toolchain
build --extra_toolchains=//bazel_toolchain:cc_cf_host_toolchain
build --verbose_failures
build --define=PREFIX=${PREFIX}
build --define=PROTOC_PREFIX=${BUILD_PREFIX}
build --define=PROTOBUF_INCLUDE_PATH=${PREFIX}/include
build --local_resources=cpu=${CPU_COUNT}
build --define=with_cross_compiler_support=true
EOF

# Prepare systemlibs defintions
mkdir -p third_party/systemlibs
cp -ap "${PREFIX}/share/bazel/systemlibs/absl" third_party/systemlibs/
cp -ap "${PREFIX}/share/bazel/systemlibs/protobuf" third_party/systemlibs/
cp -ap "${PREFIX}/share/bazel/protobuf/bazel" third_party/systemlibs/protobuf/

export ABSEIL_VERSION="$(conda list -p "${PREFIX}" libabseil --fields version | awk '!/^#/ && NF { print $1; exit }')"
export PROTOC_VERSION="$(conda list -p "${PREFIX}" libprotobuf --fields version | awk '!/^#/ && NF { print $1; exit }' | sed -E 's/^[0-9]+\.([0-9]+\.[0-9]+)$/\1/')"
sed -i "s:PROTOC_VERSION:${PROTOC_VERSION}:" MODULE.bazel
sed -i "s:ABSEIL_VERSION:${ABSEIL_VERSION}:" \
    MODULE.bazel \
    third_party/systemlibs/absl/MODULE.bazel \
    third_party/systemlibs/protobuf/MODULE.bazel

cp release/pyproject.toml release/setup.py .
# Substitute $VERSION in pyproject.toml with the value of VERSION.
sed -i "s/\$VERSION/${PKG_VERSION}/g" pyproject.toml
rm -f cel_expr_python/*_test.py
$PYTHON -m pip install -vvv .
bazel clean --expunge
