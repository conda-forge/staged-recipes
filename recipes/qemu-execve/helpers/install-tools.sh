#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}"/bin
for tool in qemu-edid qemu-ga qemu-img qemu-io qemu-nbd qemu-storage-daemon qemu-pr-helper qemu-vmsr-helper
do
  install -m 0755 "${SRC_DIR}/_conda_install/bin/${tool}" "${PREFIX}/bin/${tool}"
done
