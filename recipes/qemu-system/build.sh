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

if [[ ${target_platform} == win-* ]]; then
  qemu_args+=(
    "--datadir=share/qemu"
    "--disable-install-blobs"
  )
    #"--disable-attr"
  build_install_qemu_win "${SRC_DIR}/_conda-build" "${local_install_dir}" "${qemu_args[@]}"
else
  build_install_qemu "${SRC_DIR}/_conda-build" "${local_install_dir}" "${qemu_args[@]}"
fi
