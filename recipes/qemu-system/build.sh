#!/usr/bin/env bash

set -euxo pipefail

# --- Copy-only mode for extras package (static assets) ---
if [[ "${CONDA_QEMU_COPY_ONLY:-}" == "true" ]]; then
  echo "Copying static assets for extras package..."

  # Determine target directory (Windows uses Library/ prefix)
  if [[ "${target_platform}" == "win-"* ]]; then
    SHARE_DIR="${_PREFIX_}/Library/share"
  else
    SHARE_DIR="${PREFIX}/share"
  fi

  # Desktop file (in ui/, not ui/icons/)
  mkdir -p "${SHARE_DIR}/applications"
  cp "${SRC_DIR}/qemu_source/ui/qemu.desktop" "${SHARE_DIR}/applications/"

  # Icons (multiple sizes)
  for size in 16x16 24x24 32x32 48x48 64x64 128x128 256x256 512x512; do
    mkdir -p "${SHARE_DIR}/icons/hicolor/${size}/apps"
    cp "${SRC_DIR}/qemu_source/ui/icons/qemu_${size}.png" \
       "${SHARE_DIR}/icons/hicolor/${size}/apps/qemu.png"
  done

  # BMP and SVG icons
  mkdir -p "${SHARE_DIR}/icons/hicolor/scalable/apps"
  cp "${SRC_DIR}/qemu_source/ui/icons/qemu_32x32.bmp" \
     "${SHARE_DIR}/icons/hicolor/32x32/apps/qemu.bmp"
  cp "${SRC_DIR}/qemu_source/ui/icons/qemu.svg" \
     "${SHARE_DIR}/icons/hicolor/scalable/apps/qemu.svg"

  # Device tree blobs (all in pc-bios/dtb/)
  mkdir -p "${SHARE_DIR}/qemu/dtb"
  for dtb in bamboo canyonlands pegasos1 pegasos2 petalogix-ml605 petalogix-s3adsp1800; do
    cp "${SRC_DIR}/qemu_source/pc-bios/dtb/${dtb}.dtb" "${SHARE_DIR}/qemu/dtb/"
  done

  # Keymaps
  mkdir -p "${SHARE_DIR}/qemu/keymaps"
  cp "${SRC_DIR}/qemu_source/pc-bios/keymaps/sl" "${SHARE_DIR}/qemu/keymaps/"
  cp "${SRC_DIR}/qemu_source/pc-bios/keymaps/sv" "${SHARE_DIR}/qemu/keymaps/"

  echo "Extras package assets copied successfully."
  exit 0
fi

source "${RECIPE_DIR}/helpers/build_install_qemu.sh"

# --- Main ---

# Ensure PYTHON is set for QEMU's configure
if [[ "${target_platform}" == "linux-"* ]] || [[ "${target_platform}" == "osx-"* ]]; then
  export PYTHON="${BUILD_PREFIX}"/bin/python
  export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH}"
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
  build_install_qemu "${SRC_DIR}/_conda-build" "${PREFIX}" "${qemu_args[@]}"
else
  qemu_args+=(
    "--datadir=share/qemu"
    "--disable-install-blobs"
  )
    #"--disable-attr"
  build_install_qemu_non_unix "${SRC_DIR}/_conda-build" "${_PREFIX_}/Library" "${qemu_args[@]}"
fi
