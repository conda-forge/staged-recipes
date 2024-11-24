#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_qemu.sh"

# --- Main ---

qemu_arch=$1
if [ "${qemu_arch}" == "ppc64le" ]; then
  sysroot_arch="powerpc64le"
else
  sysroot_arch="${qemu_arch}"
fi

build_linux_qemu \
  ${qemu_arch} \
  "${sysroot_arch}-conda-linux-gnu-" \
  "${BUILD_PREFIX}/${sysroot_arch}-conda-linux-gnu/sysroot" \
  "${SRC_DIR}/_conda-build-${qemu_arch}" \
  "${SRC_DIR}/_conda-install-${qemu_arch}"

