#!/usr/bin/env bash

set -euxo pipefail

mkdir -p "${PREFIX}"/bin
install -m 0755 "${SRC_DIR}/_conda-install-ppc64le/bin/qemu-ppc64le" "${PREFIX}/bin/qemu-execve-ppc64le"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for SCRIPT in "activate" "deactivate"
do
  mkdir -p "${PREFIX}/etc/conda/${SCRIPT}.d"
  install -m 0755 "${RECIPE_DIR}/scripts/${SCRIPT}-ppc64le.sh" "${PREFIX}/etc/conda/${SCRIPT}.d/${PKG_NAME}-${SCRIPT}.sh"
done