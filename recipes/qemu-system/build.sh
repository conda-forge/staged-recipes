#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}/helpers/build_install_qemu.sh"

# --- Main ---

# Ensure PYTHON is set for QEMU's configure
if [[ "${target_platform}" == "linux-"* ]] || [[ "${target_platform}" == "osx-"* ]]; then
  export PYTHON="${BUILD_PREFIX}"/bin/python
  export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH}"
  export QEMU_INSTALL_PREFIX="${PREFIX}"
else
  export QEMU_INSTALL_PREFIX="${PREFIX}"/Library
fi

qemu_args=(
  "--disable-linux-user"
  "--disable-docs"
)

# Add target-list only if specified (arch builds)
# Empty CONDA_QEMU_TARGET means common/tools package
if [[ -n "${CONDA_QEMU_TARGET:-}" ]]; then
  qemu_args+=("--enable-system" "--target-list=${CONDA_QEMU_TARGET}-softmmu")
else
  # Common/tools package: disable system emulators
  qemu_args+=("--disable-system")

  # For common package (no tools specified), minimize dependencies
  # Only need glib/gtk for cache generation, firmware files are just copied
  if [[ -z "${CONDA_QEMU_TOOLS:-}" ]]; then
    qemu_args+=(
      # Disable block layer backends
      "--disable-curl"
      "--disable-libssh"
      "--disable-bzip2"
      "--disable-lzo"
      "--disable-snappy"
      "--disable-zstd"
      "--disable-lzfse"
      # Disable display/input
      "--disable-sdl"
      "--disable-opengl"
      "--disable-virglrenderer"
      "--disable-vnc"
      "--disable-spice-protocol"
      "--disable-curses"
      # Disable audio (pa = pulseaudio)
      "--disable-alsa"
      "--disable-jack"
      "--disable-pipewire"
      "--disable-pa"
      "--disable-oss"
      # Disable hardware/device features
      "--disable-libusb"
      "--disable-usb-redir"
      "--disable-smartcard"
      "--disable-libudev"
      "--disable-libiscsi"
      "--disable-libnfs"
      "--disable-libpmem"
      "--disable-rbd"
      "--disable-glusterfs"
      # Disable security/crypto backends
      "--disable-gnutls"
      "--disable-gcrypt"
      "--disable-nettle"
      "--disable-seccomp"
      # Disable virtualization features
      "--disable-kvm"
      "--disable-hvf"
      "--disable-whpx"
      "--disable-numa"
      "--disable-linux-aio"
      "--disable-linux-io-uring"
      "--disable-slirp"
      "--disable-vde"
      # Disable misc
      "--disable-capstone"
      "--disable-fdt"
      "--disable-guest-agent"
      "--disable-tools"
    )
  fi
fi

if [[ ${target_platform} == linux-* ]] || [[ ${target_platform} == osx-* ]]; then
  build_install_qemu "${SRC_DIR}/_conda-build" "${QEMU_INSTALL_PREFIX}" "${qemu_args[@]}"
else
  qemu_args+=(
    "--datadir=share/qemu"
  )
  build_install_qemu_non_unix "${SRC_DIR}/_conda-build" "${QEMU_INSTALL_PREFIX}" "${qemu_args[@]}"
fi

# For common package (empty target, no tools), install desktop file and icons
if [[ -z "${CONDA_QEMU_TARGET:-}" ]] && [[ -z "${CONDA_QEMU_TOOLS:-}" ]]; then
  QEMU_SRC="${SRC_DIR}/qemu_source"

  mkdir -p "${QEMU_INSTALL_PREFIX}"/share/{applications,icons}
  mkdir -p "${QEMU_INSTALL_PREFIX}"/share/icons/hicolor/{16x16,24x24,32x32,48x48,64x64,128x128,256x256,512x512,scalable}/apps
  
  # Install desktop file (in ui/, not ui/icons/)
  install -Dm644 "${QEMU_SRC}/ui/qemu.desktop" "${QEMU_INSTALL_PREFIX}/share/applications/qemu.desktop"

  # Install PNG icons (various sizes)
  for size in 16x16 24x24 32x32 48x48 64x64 128x128 256x256 512x512; do
    install -Dm644 "${QEMU_SRC}/ui/icons/qemu_${size}.png" \
      "${QEMU_INSTALL_PREFIX}/share/icons/hicolor/${size}/apps/qemu.png"
  done

  # Install BMP icon
  install -Dm644 "${QEMU_SRC}/ui/icons/qemu_32x32.bmp" \
    "${QEMU_INSTALL_PREFIX}/share/icons/hicolor/32x32/apps/qemu.bmp"

  # Install SVG icon
  install -Dm644 "${QEMU_SRC}/ui/icons/qemu.svg" \
    "${QEMU_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps/qemu.svg"
fi
