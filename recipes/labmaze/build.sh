#!/bin/bash

set -euxo pipefail

export CFLAGS="${CFLAGS} -DNDEBUG"
export CXXFLAGS="${CXXFLAGS} -DNDEBUG"

source gen-bazel-toolchain

cat >> .bazelrc <<EOF
build --crosstool_top=//bazel_toolchain:toolchain
build --logging=6
build --verbose_failures
build --toolchain_resolution_debug
build --local_cpu_resources=${CPU_COUNT}"
EOF

if [[ "${target_platform}" == "osx-arm64" ]]; then
  echo "build --cpu=${TARGET_CPU}" >> .bazelrc
fi

$PYTHON -m pip install . -vv

# Clean up to speedup postprocessing
pushd build
bazel clean
popd
