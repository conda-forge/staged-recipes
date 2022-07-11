#!/bin/bash

set -euxo pipefail

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

$PYTHON -m pip install . -vv
