#!/usr/bin/env bash
# Windows-specific workarounds for QEMU build
# These address upstream issues that may be fixed in future QEMU versions

# Pre-decompress EDK2 firmware files
# Windows bzip2.EXE has path issues with meson's decompress step
# Workaround: decompress before configure so meson finds uncompressed files
decompress_edk2_firmware() {
  local qemu_src=$1

  echo "Pre-decompressing EDK2 firmware files..."
  for bz2_file in "${qemu_src}"/pc-bios/edk2-*.fd.bz2; do
    if [[ -f "${bz2_file}" ]]; then
      local out_file="${bz2_file%.bz2}"
      if [[ ! -f "${out_file}" ]]; then
        bzip2 -dk "${bz2_file}"
        echo "  Decompressed: $(basename "${out_file}")"
      fi
    fi
  done
}

# Set up Python virtual environment with pycotap for Windows builds
# QEMU's configure creates a venv but can't find pycotap on Windows
# Workaround: Pre-create venv with pycotap + meson wrapper
# Note: Patch 0006 sets clear=False so configure won't wipe this
setup_windows_pyvenv() {
  local build_dir=$1
  local qemu_src=$2

  pushd "${build_dir}" || return 1

  # Create venv with system-site-packages for access to conda packages
  python -m venv --system-site-packages pyvenv

  # Install pycotap from vendored wheels
  ./pyvenv/Scripts/pip install --no-index \
    --find-links="${qemu_src}/python/wheels" pycotap

  # Create meson wrapper pointing to conda's meson
  # The mkvenv patch trusts the canary but doesn't create the wrapper,
  # and configure.sh expects pyvenv/Scripts/meson to exist
  local _meson_exe
  _meson_exe="$(which meson.exe 2>/dev/null || which meson)"

  if [[ -z "${_meson_exe}" ]]; then
    echo "ERROR: meson not found in PATH"
    popd || return 1
    return 1
  fi

  echo "Creating meson wrapper pointing to: ${_meson_exe}"
  local _meson_win
  _meson_win="$(cygpath -w "${_meson_exe}" 2>/dev/null || echo "${_meson_exe}")"

  # Batch file wrapper for Windows cmd
  cat > ./pyvenv/Scripts/meson.bat <<MESONBAT
@echo off
"${_meson_win}" %*
MESONBAT

  # Shell script wrapper for MSYS2/bash
  cat > ./pyvenv/Scripts/meson <<MESONSH
#!/bin/sh
exec "${_meson_exe}" "\$@"
MESONSH
  chmod +x ./pyvenv/Scripts/meson

  popd || return 1
}

# Fix Windows-specific issues in generated build.ninja
# 1. Tool names: Ensure proper .exe suffix (not doubled)
# 2. QAPI paths: Fix absolute path references that break on Windows
patch_windows_build_ninja() {
  local build_dir=$1

  pushd "${build_dir}" || return 1

  # Fix Windows tool names: ensure they have .exe suffix (but not doubled)
  # First remove any existing .exe/.EXE (case-insensitive), then add .exe back
  sed -i 's#\(windres\|nm\|windmc\)\.[eE][xX][eE]#\1#g; s#\(windres\|nm\|windmc\)\b#\1.exe#g' build.ninja

  # Fix QAPI absolute path issues
  sed -i 's#D__[^ ]*_qapi_#qapi_#g' build.ninja

  popd || return 1
}

# Full Windows setup sequence
# Usage: setup_windows_build_env <build_dir> <qemu_src>
setup_windows_build_env() {
  local build_dir=$1
  local qemu_src=$2

  decompress_edk2_firmware "${qemu_src}"
  setup_windows_pyvenv "${build_dir}" "${qemu_src}"
}
