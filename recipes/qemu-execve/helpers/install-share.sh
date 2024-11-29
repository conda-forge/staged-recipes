#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}"/include
install -m 0644 "${SRC_DIR}/_conda_install/include/qemu-plugin.h" "${PREFIX}/include/qemu-plugin.h"

# Install all the files in the share directory
mkdir -p "${PREFIX}"/share
tar -c -f - -C "${SRC_DIR}/_conda_install/share" . | tar -x -f - -C "${PREFIX}/share"
