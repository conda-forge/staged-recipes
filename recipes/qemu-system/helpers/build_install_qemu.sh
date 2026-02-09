build_install_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  export PKG_CONFIG="${BUILD_PREFIX}/bin/pkg-config"
  export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig"

  # Platform-specific configure flags
  local platform_args=()
  if [[ "${target_platform}" == osx-* ]]; then
    # Disable apple-gfx (pvg) - requires macOS 12+ SDK
    platform_args+=(--disable-pvg)
  fi

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      "${platform_args[@]}" \
      --enable-strip

    if [[ -n "${CONDA_QEMU_TOOLS:-}" ]]; then
      read -ra TOOLS_ARRAY <<< ${CONDA_QEMU_TOOLS}
      ninja -j"${CPU_COUNT}" "${TOOLS_ARRAY[@]}"
    else
      ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
    fi
    
    # ninja check > "${SRC_DIR}"/_check.log 2>&1
    ninja install > "${SRC_DIR}"/_install.log 2>&1

    # macOS: Strip extended attributes before codesigning
    if [[ "${target_platform}" == osx-* ]]; then
      xattr -cr "${install_dir}"
    fi
  popd || exit 1
}

build_install_qemu_non_unix() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("${@:-}")

  local _pkg_config="$(which pkg-config | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  local _pkg_config_path="$(echo ${PREFIX}/Library/lib/pkgconfig | sed 's|^/\(.\)|\1:|g' | sed 's|/|\\|g')"
  export PKG_CONFIG="${_pkg_config}"
  export PKG_CONFIG_PATH="${_pkg_config_path}"
  export PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    # Pre-create pyvenv with pycotap installed
    # Patch 0006 sets clear=False so configure won't wipe this
    python -m venv --system-site-packages pyvenv
    ./pyvenv/Scripts/pip install --no-index \
      --find-links="${SRC_DIR}/qemu_source/python/wheels" pycotap

    # Create meson wrapper in pyvenv/Scripts/ pointing to conda's meson
    # The mkvenv patch trusts the canary but doesn't create the wrapper,
    # and configure.sh expects pyvenv/Scripts/meson to exist
    local _meson_exe
    _meson_exe="$(which meson.exe 2>/dev/null || which meson)"
    if [[ -n "${_meson_exe}" ]]; then
      echo "Creating meson wrapper pointing to: ${_meson_exe}"
      # Convert MSYS path to Windows path for the batch file
      local _meson_win
      _meson_win="$(cygpath -w "${_meson_exe}" 2>/dev/null || echo "${_meson_exe}")"

      # Create a batch file wrapper that calls the real meson
      cat > ./pyvenv/Scripts/meson.bat <<MESONBAT
@echo off
"${_meson_win}" %*
MESONBAT

      # Also create a shell script version for MSYS2/bash
      cat > ./pyvenv/Scripts/meson <<MESONSH
#!/bin/sh
exec "${_meson_exe}" "\$@"
MESONSH
      chmod +x ./pyvenv/Scripts/meson
    else
      echo "ERROR: meson not found in PATH"
      exit 1
    fi

    # Configure will find: meson (wrapper), pycotap (pre-installed)
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      "${qemu_args[@]}" \
      --enable-strip

    sed -i 's#\(windres\|nm\|windmc\)\b#\1.exe#g' build.ninja
    sed -i 's#D__[^ ]*_qapi_#qapi_#g' build.ninja

    MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
    ninja install
  popd || exit 1
}
