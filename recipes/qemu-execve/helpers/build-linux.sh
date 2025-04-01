#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_qemu.sh"

# --- Main ---

install_dir="${1:-_conda_install}"

qemu_args=(
  "--disable-linux-user"
)
export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="${BUILD_PREFIX}/lib/pkgconfig"

build_dir="${SRC_DIR}/_conda_build"

_configure_qemu "${build_dir}" "${SRC_DIR}/${install_dir}" "${qemu_args[@]:-}"
_build_qemu "${build_dir}" "${SRC_DIR}/${install_dir}" "${qemu_args[@]:-}"
