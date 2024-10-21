#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}"/include
install -m 0644 "${SRC_DIR}/_conda-install-aarch64/include/qemu-plugin.h" "${PREFIX}/include/qemu-plugin.h"

# Install all the files in the share directory
mkdir -p "${PREFIX}"/share
cp -r "${SRC_DIR}/_conda-install-aarch64/share" "${PREFIX}"
