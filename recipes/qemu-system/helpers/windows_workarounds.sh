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

  # Native meson.exe launcher, copied under BOTH the extensioned name
  # (pyvenv/Scripts/meson.exe) and the bare extensionless name
  # (pyvenv/Scripts/meson).
  #
  # Why both: meson's own self-regeneration (its REGENERATE_BUILD ninja
  # edge, which QEMU's config-poison.h custom_target -- among others --
  # depends on) re-derives its own "meson" self-invocation command
  # independently of how configure originally invoked it, and on Windows
  # this self-derived command is the bare "pyvenv/Scripts/meson" path
  # WITHOUT a .exe suffix -- confirmed via CI log: even though configure's
  # own $meson variable correctly resolved to the .exe path (see
  # patches/0002-non-unix-configure-pyvenv.patch), the COMMAND baked into
  # build.ninja for the config-poison.h custom target was still the bare,
  # unsuffixed path. Worse, this regeneration is NOT a one-time event: the
  # real `ninja -j...` build invocation (in build_install_qemu_non_unix)
  # was observed to trigger ANOTHER implicit "Regenerating build files"
  # pass even after the earlier forced `ninja build.ninja` + sed-patch
  # dance (patch_windows_build_ninja) had already fixed the extension --
  # silently re-clobbering the sed fix with a freshly regenerated,
  # unpatched build.ninja before the real build reaches that target.
  #
  # A previous fix attempt (a bare "#!/bin/sh exec ..." shebang script at
  # this same extensionless path) cannot work here regardless of timing:
  # ninja calls CreateProcess directly on the command's first argument
  # (no cmd.exe / shell in between for this custom_target), and
  # CreateProcess does not understand '#!' shebangs -- hence
  # "ninja: fatal: CreateProcess: %1 is not a valid Win32 application."
  #
  # CreateProcess itself does NOT care about file extension, only about
  # whether the target file's CONTENT is a valid PE image. So instead of
  # trying to control which name meson/ninja happens to bake in (a losing
  # race against an implicit regen we don't control the timing of), make
  # BOTH names valid native executables: copy conda's real meson.exe
  # launcher to both paths. Whichever spelling ninja ends up invoking --
  # with or without .exe, after any number of regens -- CreateProcess
  # succeeds.
  if [[ -f "${_meson_exe}" && "${_meson_exe}" == *.exe ]]; then
    cp "${_meson_exe}" ./pyvenv/Scripts/meson.exe
    cp "${_meson_exe}" ./pyvenv/Scripts/meson
    echo "DEBUG: copied real meson.exe launcher from ${_meson_exe} to ./pyvenv/Scripts/meson.exe and ./pyvenv/Scripts/meson"
  else
    echo "WARNING: meson resolved to '${_meson_exe}' (not a .exe) — native meson.exe/meson copies not created; configure's patched meson= path and meson's self-regen commands will fall back to a non-executable path and fail under ninja.exe"
  fi

  # DEBUG (temporary, CI investigation only): confirm all wrapper/launcher
  # files exist side by side. meson and meson.exe are now both binary PE
  # copies, so don't head/cat them (binary to the log); just list sizes.
  echo "DEBUG: listing pyvenv/Scripts/meson launcher files"
  ls -la ./pyvenv/Scripts/meson* 2>/dev/null || true
  echo "DEBUG: first line of ./pyvenv/Scripts/meson.bat (batch wrapper):"
  head -1 ./pyvenv/Scripts/meson.bat 2>/dev/null || true

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
  sed -i 's#\(windres\|nm\|windmc\|meson\)\.[eE][xX][eE]#\1#g; s#\(windres\|nm\|windmc\|meson\)\b#\1.exe#g' build.ninja

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
