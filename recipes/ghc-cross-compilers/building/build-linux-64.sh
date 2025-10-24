#!/usr/bin/env bash
set -eu

_log_index=0

source "${RECIPE_DIR}"/building/common.sh

# in 9.12+ we can use x86_64-conda-linux-gnu
conda_host="${build_alias}"
conda_target="${triplet}"
host_arch="${build_alias%%-*}"
target_arch="${conda_target%%-*}"

ghc_host="${host_arch}-unknown-linux-gnu"
ghc_target="${target_arch}-unknown-linux-gnu"

_build_alias=${build_alias}
_host_alias=${host_alias}
export build_alias="${ghc_host}"
export host_alias="${ghc_host}"

ghc_path="${BUILD_PREFIX}"/ghc-bootstrap/bin
export GHC="${ghc_path}"/ghc

"${ghc_path}"/ghc-pkg recache

export CABAL="${BUILD_PREFIX}"/bin/cabal
export CABAL_DIR="${SRC_DIR}"/.cabal

mkdir -p "${CABAL_DIR}" && "${CABAL}" user-config init
run_and_log "cabal-update" "${CABAL}" v2-update

echo "Creating cross environment for cross-compilation libraries..."
conda create -y \
    -n cross_env \
    --platform "${cross_target_platform}" \
    -c conda-forge \
    gmp \
    libffi \
    libiconv \
    ncurses

sleep 10

# Get the environment path and set up library paths
CROSS_ENV_PATH=$(conda info --envs | grep cross_env | awk '{print $2}')
export CROSS_LIB_DIR="${CROSS_ENV_PATH}/lib"
export CROSS_INCLUDE_DIR="${CROSS_ENV_PATH}/include"

CROSS_CFLAGS=$(echo "$CFLAGS" | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
CROSS_CXXFLAGS=$(echo "$CXXFLAGS" | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
CROSS_CPPFLAGS=$(echo "$CPPFLAGS" | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')

if [[ "${target_arch}" == "aarch64" ]]; then
  CROSS_CFLAGS=$(echo "$CROSS_CFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
  CROSS_CXXFLAGS=$(echo "$CROSS_CXXFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
  CROSS_CPPFLAGS=$(echo "$CROSS_CPPFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
fi

echo "cross libraries located at: ${CROSS_LIB_DIR}"
echo "cross headers located at: ${CROSS_INCLUDE_DIR}"

# Configure and build GHC
SYSTEM_CONFIG=(
  --target="${ghc_target}"
  --prefix="${PREFIX}"
)

CONFIGURE_ARGS=(
  --with-system-libffi=yes
  --with-curses-includes="${CROSS_INCLUDE_DIR}"
  --with-curses-libraries="${CROSS_LIB_DIR}"
  --with-ffi-includes="${CROSS_INCLUDE_DIR}"
  --with-ffi-libraries="${CROSS_LIB_DIR}"
  --with-gmp-includes="${CROSS_INCLUDE_DIR}"
  --with-gmp-libraries="${CROSS_LIB_DIR}"
  --with-iconv-includes="${CROSS_INCLUDE_DIR}"
  --with-iconv-libraries="${CROSS_LIB_DIR}"
  ac_cv_lib_ffi_ffi_call=yes
  AR="${conda_target}"-ar
  AS="${conda_target}"-as
  CC="${conda_target}"-clang
  CXX="${conda_target}"-clang++
  LD="${conda_target}"-ld
  NM="${conda_target}"-nm
  OBJDUMP="${conda_target}"-objdump
  RANLIB="${conda_target}"-ranlib
  LDFLAGS="-L${CROSS_ENV_PATH}/lib ${LDFLAGS:-}"
)

run_and_log "ghc-configure" ./configure "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}"

# Fix host configuration to use x86_64, target cross
settings_file="${SRC_DIR}"/hadrian/cfg/system.config
perl -pi -e "s#${BUILD_PREFIX}/bin/##" "${settings_file}"
perl -pi -e "s#(=\s+)(ar|clang|clang\+\+|llc|nm|opt|ranlib)\$#\$1${conda_target}-\$2#" "${settings_file}"
perl -pi -e "s#(conf-gcc-linker-args-stage[12].*?= )#\$1-Wl,-L${CROSS_ENV_PATH}/lib -Wl,-rpath,${CROSS_ENV_PATH}/lib#" "${settings_file}"
perl -pi -e "s#(conf-ld-linker-args-stage[12].*?= )#\$1-L${CROSS_ENV_PATH}/lib -rpath ${CROSS_ENV_PATH}/lib#" "${settings_file}"
perl -pi -e "s#(settings-c-compiler-link-flags.*?= )#\$1-Wl,-L${CROSS_ENV_PATH}/lib -Wl,-rpath,${CROSS_ENV_PATH}/lib#" "${settings_file}"
perl -pi -e "s#(settings-c-compiler-link-flags.*?= )#\$1-Wl,-L${CROSS_ENV_PATH}/lib -Wl,-rpath,${CROSS_ENV_PATH}/lib#" "${settings_file}"
perl -pi -e "s#(settings-merge-objects-command.*?= ).*#\$1${conda_target}-ld#" "${settings_file}"
perl -pi -e "s#(settings-ld-flags.*?= )#\$1-L${CROSS_ENV_PATH}/lib -rpath ${CROSS_ENV_PATH}/lib#" "${settings_file}"

perl -pi -e "s#(settings-clang-command.*?= ).*#\$1${conda_target}-clang#" "${settings_file}"

_hadrian_build=("${SRC_DIR}"/hadrian/build "-j${CPU_COUNT}")

# ---| Stage 1: Cross-compiler |---

# Disable copy for cross-compilation - force building the cross binary
# Change the cross-compile copy condition to never match
perl -i -pe 's/finalStage = Stage2/finalStage = Stage1/' "${SRC_DIR}"/hadrian/src/UserSettings.hs
run_and_log "stage1_ghc-bin" "${_hadrian_build[@]}" stage1:exe:ghc-bin --flavour=quick --docs=none --progress-info=none
run_and_log "stage1_ghc-pkg" "${_hadrian_build[@]}" stage1:exe:ghc-pkg --flavour=quick --docs=none --progress-info=none
run_and_log "stage1_hsc2hs"  "${_hadrian_build[@]}" stage1:exe:hsc2hs --flavour=quick --docs=none --progress-info=none

settings_file="${SRC_DIR}"/_build/stage0/lib/settings
update_settings_link_flags "${settings_file}" "${conda_target}"
cat "${settings_file}"
run_and_log "stage1_lib" "${_hadrian_build[@]}" stage1:lib:ghc --flavour=quick --docs=none --progress-info=none
update_settings_link_flags "${settings_file}" "${conda_target}"

run_and_log "binary-dist" "${_hadrian_build[@]}" binary-dist --flavour=quick --docs=none --progress-info=none

# Now manually install from the bindist with correct configure arguments
cross_prefix="${SRC_DIR}"/cross_install && mkdir -p "${SRC_DIR}"/cross_install
bindist_dir=$(find "${SRC_DIR}"/_build/bindist -name "ghc-${PKG_VERSION}-${ghc_target}" -type d | head -1)
if [[ -n "${bindist_dir}" ]]; then
  pushd "${bindist_dir}"
    # Configure the binary distribution with proper cross-compilation settings
    CC="${conda_host}"-clang \
    CXX="${conda_host}"-clang++ \
    ./configure --prefix="${cross_prefix}" --target="${ghc_target}"

    # Install WITHOUT running update_package_db (which tries to execute aarch64 ghc-pkg)
    # We'll manually recache using the bootstrap ghc-pkg after installation
    echo "=== Installing bindist (skipping package DB update) ==="
    make install_bin install_lib install_docs install_man

    # Manually update package database using bootstrap (x86_64) ghc-pkg
    echo "=== Updating package database with bootstrap ghc-pkg ==="
    # Find the actual package.conf.d directory (path varies based on target platform)
    pkg_conf_dir=$(find "${cross_prefix}"/lib -type d -name "package.conf.d" | head -1)
    if [[ -n "${pkg_conf_dir}" ]]; then
      echo "Found package database at: ${pkg_conf_dir}"
      "${ghc_path}"/ghc-pkg --global-package-db "${pkg_conf_dir}" recache
    else
      echo "ERROR: Could not find package.conf.d directory in ${cross_prefix}/lib"
      find "${cross_prefix}"/lib -type d -name "*ghc*" || true
      exit 1
    fi
  popd
else
  echo "Error: Could not find binary distribution directory"
  exit 1
fi

# Correct CC/CXX
settings_file="$(find ${cross_prefix}/lib/ -name settings | head -1)"
if [[ -f "${settings_file}" ]]; then
  perl -pi -e "s#${host_arch}(-[^ \"]*)#${target_arch}\$1#g" "${settings_file}"
  perl -pi -e "s#(C compiler link flags\", \"[^\"]*)#\$1 -Wl,-L\\\$topdir/../../../lib -Wl,-rpath,\\\$topdir/../../../lib#" "${settings_file}"
  perl -pi -e "s#(ld flags\", \"[^\"]*)#\$1 -L\\\$topdir/../../../lib -rpath \\\$topdir/../../../lib#" "${settings_file}"
  perl -pi -e "s#\"[\$/\w]*?(ar|clang|clang\+\+|ld|ranlib|llc|opt)\"#\"${conda_target}-\$1\"#" "${settings_file}"
  cat "${settings_file}"
else
  echo "Error: Could not find settins file"
  exit 1
fi

# Create links of cross-conda-linux-gnu-xxx to xxx
pushd "${cross_prefix}"/bin
  for bin in ghc ghc-pkg hp2ps hsc2hs; do
    if [[ -f "${ghc_target}-${bin}" ]] && [[ ! -f "${conda_target}-${bin}" ]]; then
      mv "${ghc_target}-${bin}" "${conda_target}-${bin}"
      perl -pi -e "s#${cross_prefix}#\\\${PREFIX}#g" "${conda_target}-${bin}"
    fi
  done
popd
