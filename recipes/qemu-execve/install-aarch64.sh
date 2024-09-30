#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}"/bin
install -m 0755 "${SRC_DIR}/_conda-install-aarch64/bin/qemu-aarch64" "${PREFIX}/bin/qemu-execve-aarch64"
