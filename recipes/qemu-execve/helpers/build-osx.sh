#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/_build_qemu.sh"

# --- Main ---

qemu_args=(
  "--disable-linux-user"
)
export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="${BUILD_PREFIX}/lib/pkgconfig"

build_dir="${SRC_DIR}/_conda_build"
install_dir="${SRC_DIR}/_conda_install"

# libslirp-feedstock has non-responsive pending PR
# Build it locally for now
git clone https://gitlab.freedesktop.org/slirp/libslirp.git
pushd libslirp || exit 1
  meson build --prefix="${install_dir}"
  ninja -C build install
popd || exit 1

qemu_args=(
  ""
)

_configure_qemu "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
_build_qemu "${build_dir}" "${install_dir}" "${qemu_args[@]:-}"
