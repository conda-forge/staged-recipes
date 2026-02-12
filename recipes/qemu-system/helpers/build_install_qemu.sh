# Install specific QEMU tools from build directory to install directory
# Usage: install_qemu_tools <build_dir> <install_dir> <tool1> [tool2] ...
install_qemu_tools() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local tools=("$@")

  mkdir -p "${install_dir}/bin"
  mkdir -p "${install_dir}/libexec"

  for tool in "${tools[@]}"; do
    local src=""
    local dst=""

    case "${tool}" in
      # Direct binaries (build artifact name = install name)
      qemu-img*|qemu-io*|qemu-nbd*|qemu-edid*|qemu-keymap*|qemu-pr-helper*|qemu-vmsr-helper*)
        src="${build_dir}/${tool}"
        dst="${install_dir}/bin/${tool}"
        ;;
      # Binaries in subdirectories
      qemu-ga*)
        src="${build_dir}/qga/qemu-ga"
        dst="${install_dir}/bin/${tool}"
        ;;
      qemu-storage-daemon*)
        src="${build_dir}/storage-daemon/qemu-storage-daemon"
        dst="${install_dir}/bin/${tool}"
        ;;
      elf2dmp*)
        src="${build_dir}/contrib/elf2dmp/elf2dmp"
        dst="${install_dir}/bin/${tool}"
        ;;
      # Special install location
      qemu-bridge-helper*)
        src="${build_dir}/qemu-bridge-helper"
        dst="${install_dir}/libexec/${tool}"
        ;;
      *)
        echo "WARNING: Unknown tool '${tool}', skipping"
        continue
        ;;
    esac

    if [[ -f "${src}" ]]; then
      echo "Installing: ${tool} -> ${dst}"
      install -m 755 "${src}" "${dst}"
    else
      echo "ERROR: Built artifact not found: ${src}"
      return 1
    fi
  done
}

# Install shared data files (keymaps, firmware, etc.)
install_qemu_datafiles() {
  local build_dir=$1
  local install_dir=$2

  # Use meson install for data files only, or copy manually
  # For now, run full install and rely on recipe file filtering
  pushd "${build_dir}" || return 1
    meson install --destdir="${install_dir}" --no-rebuild 2>/dev/null || ninja install
  popd || return 1
}

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
      # Selective build: build and install only specified tools
      read -ra TOOLS_ARRAY <<< "${CONDA_QEMU_TOOLS}"
      echo "Building specific tools: ${TOOLS_ARRAY[*]}"
      ninja -j"${CPU_COUNT}" "${TOOLS_ARRAY[@]}"
      install_qemu_tools "${build_dir}" "${install_dir}" "${TOOLS_ARRAY[@]}"

      if [[ "${target_platform}" == linux-* ]] && [[ -n "${CONDA_QEMU_LINUX_TOOLS:-}" ]]; then
        read -ra TOOLS_ARRAY <<< "${CONDA_QEMU_LINUX_TOOLS}"
        echo "Building specific LINUX tools: ${TOOLS_ARRAY[*]}"
        ninja -j"${CPU_COUNT}" "${TOOLS_ARRAY[@]}"
        install_qemu_tools "${build_dir}" "${install_dir}" "${TOOLS_ARRAY[@]}"
      fi
    else
      # Full build and install
      ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
      ninja install > "${SRC_DIR}"/_install.log 2>&1
    fi

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
  # Prevent MSYS2 path conversion for meson/ninja subprocesses
  export MSYS2_ARG_CONV_EXCL="*"

  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    # Pre-decompress EDK2 firmware files (Windows bzip2.EXE has path issues with meson)
    echo "Pre-decompressing EDK2 firmware files..."
    for bz2_file in "${SRC_DIR}"/qemu_source/pc-bios/edk2-*.fd.bz2; do
      if [[ -f "${bz2_file}" ]]; then
        local out_file="${bz2_file%.bz2}"
        if [[ ! -f "${out_file}" ]]; then
          bzip2 -dk "${bz2_file}"
          echo "  Decompressed: $(basename "${out_file}")"
        fi
      fi
    done

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

    # Fix Windows tool names: ensure they have .exe suffix (but not doubled)
    # First remove any existing .exe/.EXE (case-insensitive), then add .exe back
    sed -i 's#\(windres\|nm\|windmc\)\.[eE][xX][eE]#\1#g; s#\(windres\|nm\|windmc\)\b#\1.exe#g' build.ninja
    sed -i 's#D__[^ ]*_qapi_#qapi_#g' build.ninja

    if [[ -n "${CONDA_QEMU_TOOLS:-}" ]]; then
      # Selective build: build and install only specified tools
      read -ra TOOLS_ARRAY <<< "${CONDA_QEMU_TOOLS}"
      TOOLS_ARRAY=("${TOOLS_ARRAY[@]/%/.exe}")
      echo "Building specific tools: ${TOOLS_ARRAY[*]}"
      MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}" "${TOOLS_ARRAY[@]}" || { echo "Build failed"; exit 1; }

      # Selective install: only install what we built
      install_qemu_tools "${build_dir}" "${install_dir}" "${TOOLS_ARRAY[@]}"
    else
      # Full build and install
      MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
      ninja install
    fi
  popd || exit 1
}
