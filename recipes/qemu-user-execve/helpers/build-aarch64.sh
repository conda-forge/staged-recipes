#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_qemu.sh"

# --- Main ---

qemu_arch="aarch64"

build_linux_qemu \
  ${qemu_arch} \
  "${qemu_arch}-conda-linux-gnu-" \
  "${BUILD_PREFIX}/${qemu_arch}-conda-linux-gnu/sysroot" \
  "${SRC_DIR}/_conda-build-${qemu_arch}" \
  "${SRC_DIR}/_conda-install-${qemu_arch}"

