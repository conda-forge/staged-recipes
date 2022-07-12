#!/bin/bash

set -euxo pipefail

export CC=$(basename $CC)
export CXX=$(basename $CXX)

source gen-bazel-toolchain

system_libs=com_google_boringssl
system_libs+=,com_google_brotli
system_libs+=,org_sourceware_bzip2
system_libs+=,com_github_cares_cares
system_libs+=,org_blosc_cblosc
system_libs+=,se_curl
system_libs+=,jpeg
system_libs+=,png
system_libs+=,org_lz4
system_libs+=,nasm
system_libs+=,org_nghttp2
system_libs+=,com_google_snappy
system_libs+=,org_tukaani_xz
system_libs+=,net_zlib
system_libs+=,net_zstd
export TENSORSTORE_SYSTEM_LIBS="$system_libs"

build_options="--define=CB_PREFIX=$PREFIX"
build_options+=" --crosstool_top=//bazel_toolchain:toolchain"
build_options+=" --logging=6"
build_options+=" --verbose_failures"
build_options+=" --toolchain_resolution_debug"
build_options+=" --local_cpu_resources=${CPU_COUNT}"
export TENSORSTORE_BAZEL_BUILD_OPTIONS="$build_options"

# replace bundled baselisk with a simpler forwarder to our own bazel in build prefix
export BAZEL_EXE="${BUILD_PREFIX}/bin/bazel"
export TENSORSTORE_BAZELISK="${RECIPE_DIR}/bazelisk_shim.py"

${PYTHON} -m pip install . -vv

# Clean up a bit to speed-up prefix post-processing
bazel clean || true
bazel shutdown || true
