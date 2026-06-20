#!/usr/bin/env bash
set -euo pipefail

# `container` is built with the system Swift toolchain (Xcode 26 / Swift 6.2),
# which conda-forge does not ship. The Package.swift requires
# `swift-tools-version: 6.2` and the project uses macOS 26 virtualization and
# networking APIs (guarded by `@available(macOS 26, *)`), so the macOS 26 SDK
# (MACOSX_SDK_VERSION=26) is required to build.
SWIFT="${SWIFT:-/usr/bin/swift}"
export SDKROOT="${CONDA_BUILD_SYSROOT}"

"${SWIFT}" build -c release

BIN_DIR="$("${SWIFT}" build -c release --show-bin-path)"

install_file() {
  local mode="$1" src="$2" dest="$3"
  mkdir -p "$(dirname "${dest}")"
  install -m "${mode}" "${src}" "${dest}"
}

# Install layout mirrors the upstream Makefile `$(STAGING_DIR)` target, rooted at
# $PREFIX. `container` derives its install root as the grandparent of the binary
# path ($PREFIX/bin/container -> $PREFIX), so it finds the plugins under
# $PREFIX/libexec/container/plugins automatically.
install_file 0755 "${BIN_DIR}/container"                      "${PREFIX}/bin/container"
install_file 0755 "${BIN_DIR}/container-apiserver"            "${PREFIX}/bin/container-apiserver"
install_file 0755 "${SRC_DIR}/scripts/update-container.sh"    "${PREFIX}/bin/update-container.sh"
install_file 0755 "${SRC_DIR}/scripts/uninstall-container.sh" "${PREFIX}/bin/uninstall-container.sh"

install_file 0755 "${BIN_DIR}/container-runtime-linux" \
  "${PREFIX}/libexec/container/plugins/container-runtime-linux/bin/container-runtime-linux"
install_file 0644 "${SRC_DIR}/Sources/Plugins/RuntimeLinux/config.toml" \
  "${PREFIX}/libexec/container/plugins/container-runtime-linux/config.toml"

install_file 0755 "${BIN_DIR}/container-network-vmnet" \
  "${PREFIX}/libexec/container/plugins/container-network-vmnet/bin/container-network-vmnet"
install_file 0644 "${SRC_DIR}/Sources/Plugins/NetworkVmnet/config.toml" \
  "${PREFIX}/libexec/container/plugins/container-network-vmnet/config.toml"

install_file 0755 "${BIN_DIR}/container-core-images" \
  "${PREFIX}/libexec/container/plugins/container-core-images/bin/container-core-images"
install_file 0644 "${SRC_DIR}/Sources/Plugins/CoreImages/config.toml" \
  "${PREFIX}/libexec/container/plugins/container-core-images/config.toml"

install_file 0755 "${BIN_DIR}/machine-apiserver" \
  "${PREFIX}/libexec/container/plugins/machine-apiserver/bin/machine-apiserver"
install_file 0644 "${SRC_DIR}/Sources/Plugins/MachineAPIServer/config.toml" \
  "${PREFIX}/libexec/container/plugins/machine-apiserver/config.toml"
install_file 0755 "${SRC_DIR}/Sources/Plugins/MachineAPIServer/Resources/init" \
  "${PREFIX}/libexec/container/plugins/machine-apiserver/resources/init"
install_file 0755 "${SRC_DIR}/Sources/Plugins/MachineAPIServer/Resources/create-user.sh" \
  "${PREFIX}/libexec/container/plugins/machine-apiserver/resources/create-user.sh"
