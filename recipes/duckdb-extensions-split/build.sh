#!/bin/bash

set -exuo pipefail


# PKG_PREFIX="duckdb-extension-"
# EXTENSION_NAME="${PKG_NAME#$PKG_PREFIX}"  # This doesn't seem to work.
# env | grep 'duckdb-extension-json'
EXTENSION_NAME='json'

export DUCKDB_EXTENSIONS="${EXTENSION_NAME}"
export BUILD_EXTENSIONS_ONLY='1'
export DISABLE_PARQUET='1'
# export DUCKDB_VERSION="${PKG_VERSION}"  # This doensn't seem to do anything.
# export GIT_COMMIT_HASH="${PKG_VERSION}-0-g4a89d97"  # This doesn't work. I need to run cmake first, I think.

make

mkdir -p "${PREFIX}"/duckdb/extensions/
touch "${PREFIX}"/duckdb/extensions/test.txt
cp ./build/release/repository/v..1-dev/*/"${EXTENSION_NAME}".duckdb_extension "${PREFIX}"/duckdb/extensions/
