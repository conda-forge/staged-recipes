#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}"/bin
install -m 0755 "${SRC_DIR}/_conda-install-ppc64le/bin/qemu-ppc64le" "${PREFIX}/bin/qemu-execve-ppc64le"
