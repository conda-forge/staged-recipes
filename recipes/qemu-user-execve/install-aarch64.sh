#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}"/bin
install -m 0755 "${SRC_DIR}/_conda-install-aarch64/bin/qemu-aarch64" "${PREFIX}/bin/${PKG_NAME}e-aarch64"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for SCRIPT in "activate" "deactivate"
do
  mkdir -p "${PREFIX}/etc/conda/${SCRIPT}.d"
  install -m 0755 "${RECIPE_DIR}/scripts/${SCRIPT}-aarch64.sh" "${PREFIX}/etc/conda/${SCRIPT}.d/${PKG_NAME}-${SCRIPT}.sh"
done