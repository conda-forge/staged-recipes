SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Helper Functions ---

is_unix() { [[ "${target_platform}" == "linux-"* || "${target_platform}" == "osx-"* ]]; }

setup_nu_pyvenv() {
  local build_dir=$1
  local qemu_src=$2

  pushd "${build_dir}" || return 1
  python -m venv --system-site-packages pyvenv
  ./pyvenv/Scripts/pip install --no-index  --find-links="${qemu_src}/python/wheels" pycotap

  local _meson_exe
  _meson_exe="$(which meson.exe 2>/dev/null || which meson 2>/dev/null)" || _meson_exe=""
  [[ -z "${_meson_exe}" ]] && { echo "ERROR: meson not found in PATH" >&2; popd || return 1; return 1; }

  echo "Creating meson wrapper pointing to: ${_meson_exe}"
  local _meson_win
  _meson_win="$(cygpath -w "${_meson_exe}" 2>/dev/null || echo "${_meson_exe}")"

  cat > ./pyvenv/Scripts/meson.bat <<MESONBAT
@echo off
"${_meson_win}" %*
MESONBAT

  # Native meson.exe launcher, copied under BOTH the extensioned and the bare name
  if [[ -f "${_meson_exe}" && "${_meson_exe}" == *.exe ]]; then
    cp "${_meson_exe}" ./pyvenv/Scripts/meson.exe
    cp "${_meson_exe}" ./pyvenv/Scripts/meson
  else
    echo "WARNING: meson resolved to '${_meson_exe}' (not a .exe)"
  fi

  popd || return 1
}

setup_nu_build_env() {
  local build_dir=$1
  local qemu_src=$2

  for bz2_file in "${qemu_src}"/pc-bios/edk2-*.fd.bz2; do
    if [[ -f "${bz2_file}" ]]; then
      local out_file="${bz2_file%.bz2}"
      if [[ ! -f "${out_file}" ]]; then
        bzip2 -dk "${bz2_file}"
      fi
    fi
  done
  setup_nu_pyvenv "${build_dir}" "${qemu_src}"
}

patch_nu_build_ninja() {
  local build_dir=$1

  pushd "${build_dir}" || return 1
    sed -i 's#\(windres\|nm\|windmc\|meson\)\.[eE][xX][eE]#\1#g; s#\(windres\|nm\|windmc\|meson\)\b#\1.exe#g' build.ninja
    sed -i 's#D__[^ ]*_qapi_#qapi_#g' build.ninja
  popd || return 1
}

# --- Main Function ---

build_install_qemu() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local qemu_args=("$@")

  local strip_arg="--enable-strip"
  [[ "${target_platform}" == osx-* ]] && strip_arg="--disable-strip"     # Strip conflicts with code signing on macOS

  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"

  if ! is_unix; then
    export PATH="${BUILD_PREFIX}/Library/mingw-w64/bin:${BUILD_PREFIX}/Library/bin:${PATH}"
    setup_nu_build_env "${build_dir}" "${SRC_DIR}/qemu_source"
  fi
  
  pushd "${build_dir}" || exit 1
    ${SRC_DIR}/qemu_source/configure \
      --prefix="${install_dir}" \
      --disable-download \
      "${qemu_args[@]}" \
      ${strip_arg} > "${SRC_DIR}"/_configure.log 2>&1 || { cat "${SRC_DIR}"/_configure.log; exit 1; }

    # Build and install
    if ! is_unix; then
      # Force meson's implicit self-regeneration of build.ninja (its
      # REGENERATE_BUILD ninja edge) to run and complete now, BEFORE we patch
      # build.ninja below -- otherwise the first real `ninja` invocation later
      # triggers this same regen internally and silently overwrites our sed
      # fix with a freshly-regenerated, unpatched build.ninja.
      ninja build.ninja > "${SRC_DIR}"/_regen.log 2>&1 || { cat "${SRC_DIR}"/_regen.log; exit 1; }
      patch_nu_build_ninja "${build_dir}"
    fi
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
