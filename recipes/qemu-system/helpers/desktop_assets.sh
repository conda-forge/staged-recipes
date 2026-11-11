#!/usr/bin/env bash
# QEMU desktop assets installation (icons, desktop files)
# Used by common package to install UI integration files

# Install QEMU desktop file and icons
# Usage: install_qemu_desktop_assets <qemu_src> <install_prefix>
install_qemu_desktop_assets() {
  local qemu_src=$1
  local install_prefix=$2

  # Create icon directories
  mkdir -p "${install_prefix}"/share/{applications,icons}
  mkdir -p "${install_prefix}"/share/icons/hicolor/{16x16,24x24,32x32,48x48,64x64,128x128,256x256,512x512,scalable}/apps

  # Install desktop file (in ui/, not ui/icons/)
  install -Dm644 "${qemu_src}/ui/qemu.desktop" \
    "${install_prefix}/share/applications/qemu.desktop"

  # Install PNG icons (various sizes)
  for size in 16x16 24x24 32x32 48x48 64x64 128x128 256x256 512x512; do
    install -Dm644 "${qemu_src}/ui/icons/qemu_${size}.png" \
      "${install_prefix}/share/icons/hicolor/${size}/apps/qemu.png"
  done

  # Install BMP icon (32x32 only)
  install -Dm644 "${qemu_src}/ui/icons/qemu_32x32.bmp" \
    "${install_prefix}/share/icons/hicolor/32x32/apps/qemu.bmp"

  # Install SVG icon (scalable)
  install -Dm644 "${qemu_src}/ui/icons/qemu.svg" \
    "${install_prefix}/share/icons/hicolor/scalable/apps/qemu.svg"
}
