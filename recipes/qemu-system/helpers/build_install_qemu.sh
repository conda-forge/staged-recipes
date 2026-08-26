SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/windows_workarounds.sh"

# Build and install QEMU for Unix platforms (Linux, macOS)
# Usage: build_install_qemu <build_dir> <install_dir> [configure_args...]
build_install_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("$@")

  local strip_arg="--enable-strip"
  [[ "${target_platform}" == osx-* ]] && strip_arg="--disable-strip"     # Strip conflicts with code signing on macOS

  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"
  pushd "${build_dir}" || exit 1
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      --disable-download \
      "${qemu_args[@]}" \
      ${strip_arg} > "${SRC_DIR}"/_configure.log 2>&1 || { cat "${SRC_DIR}"/_configure.log; exit 1; }

    # Build and install
    ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
    ninja install > "${SRC_DIR}"/_install.log 2>&1 || { cat "${SRC_DIR}"/_install.log; exit 1; }

    # macOS: Strip extended attributes before codesigning
    if [[ "${target_platform}" == osx-* ]]; then
      xattr -cr "${install_dir}"
    fi

    # Clean up QEMU meson build artifacts that shouldn't be installed
    rm -f "${install_dir}/bin/"*-unsigned 2>/dev/null || true
  popd || exit 1
}

# Build and install QEMU for Windows (MSYS2/MinGW)
# Usage: build_install_qemu_non_unix <build_dir> <install_dir> [configure_args...]
build_install_qemu_non_unix() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("$@")

  export PATH="${BUILD_PREFIX}/Library/mingw-w64/bin:${BUILD_PREFIX}/Library/bin:${PATH}"

  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"

  # Windows-specific pre-configure setup
  setup_windows_build_env "${build_dir}" "${SRC_DIR}/qemu_source"

  pushd "${build_dir}" || exit 1
    # Configure
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      --disable-download \
      "${qemu_args[@]}" \
      --enable-strip > "${SRC_DIR}"/_configure.log 2>&1 || { cat "${SRC_DIR}"/_configure.log; exit 1; }

    # Force meson's implicit self-regeneration of build.ninja (its
    # REGENERATE_BUILD ninja edge) to run and complete now, BEFORE we patch
    # build.ninja below -- otherwise the first real `ninja` invocation later
    # triggers this same regen internally and silently overwrites our sed
    # fix with a freshly-regenerated, unpatched build.ninja.
    MSYS2_ARG_CONV_EXCL="*" ninja build.ninja > "${SRC_DIR}"/_regen.log 2>&1 || { cat "${SRC_DIR}"/_regen.log; exit 1; }

    # Apply Windows build.ninja fixes
    patch_windows_build_ninja "${build_dir}"

    # Build and install
    MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}" > "${SRC_DIR}"/_make.log 2>&1 || { cat "${SRC_DIR}"/_make.log; exit 1; }
    ninja install > "${SRC_DIR}"/_install.log 2>&1 || { cat "${SRC_DIR}"/_install.log; exit 1; }

  popd || exit 1
}
