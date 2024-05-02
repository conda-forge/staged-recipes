# !/bin/bash

set -exuo pipefail

if [ "${target_platform}" = "linux-64" ]; then
    DUCKDB_ARCH='linux_amd64'
elif [ "${target_platform}" = "osx-64" ]; then
    DUCKDB_ARCH='osx_amd64'
elif [ "${target_platform}" = "osx-arm64" ]; then
    DUCKDB_ARCH='osx_arm64'
else
    echo "Unknown target platform: ${target_platform}"
    exit 1
fi

make \
    BUILD_EXTENSIONS="json;httpfs" \
    SKIP_EXTENSIONS="parquet;jemalloc" \
    BUILD_EXTENSIONS_ONLY="1" \
    OVERRIDE_GIT_DESCRIBE="v${PKG_VERSION}-0-g4a89d97"
