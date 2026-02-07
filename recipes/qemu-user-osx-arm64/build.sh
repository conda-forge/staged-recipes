#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/build_install_qemu.sh"

# --- Main ---

install_dir="${CONDA_QEMU_INSTALL_DIR:-\"_conda_install\"}"

local_install_dir="${PREFIX}"
if [[ "${install_dir}" != ${PREFIX} ]]; then
  local_install_dir="${SRC_DIR}/${install_dir}"
fi

qemu_args=(
  "--enable-system"
  "--disable-linux-user"
)

build_install_qemu "${SRC_DIR}/_conda-build" "${local_install_dir}" "${qemu_args[@]}"

# Rattler-build: Only files installed in prefix will remain in the build cache
if [[ ${install_dir} != ${PREFIX} ]]; then
  tar -cf - -C "${SRC_DIR}" "${install_dir}" | tar -xf - -C "${PREFIX}"
fi