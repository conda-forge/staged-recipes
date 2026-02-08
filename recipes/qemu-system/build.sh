#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/build_install_qemu.sh"

# --- Main ---

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH}"

install_dir="${CONDA_QEMU_INSTALL_DIR:-_conda_install}"

local_install_dir="${PREFIX}"
if [[ "${install_dir}" != ${PREFIX} ]]; then
  local_install_dir="${SRC_DIR}/${install_dir}"
fi

qemu_args=(
  "--enable-system"
  "--disable-linux-user"
)

if [[ ${target_platform} == linux-* ]] || [[ ${target_platform} == osx-* ]]; then
  build_install_qemu "${SRC_DIR}/_conda-build" "${local_install_dir}" "${qemu_args[@]}"
else
  qemu_args+=(
    "--datadir=share/qemu"
    "--disable-install-blobs"
    "--disable-docs"
  )
    #"--disable-attr"
  build_install_qemu_non_unix "${SRC_DIR}/_conda-build" "${local_install_dir}" "${qemu_args[@]}"
fi
