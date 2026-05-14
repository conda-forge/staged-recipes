#!/usr/bin/env bash
set -eu

_log_index=0

source "${RECIPE_DIR}"/building/common.sh

# Detect platform configuration
detect_platform_config "${target_platform}"

# in 9.12+ we can use x86_64-conda-linux-gnu
conda_host="${build_alias}"
conda_target="${triplet}"

host_arch="${conda_host%%-*}"
target_arch="${conda_target%%-*}"

ghc_host="${host_arch}${GHC_OS_SUFFIX}"
ghc_target="${target_arch}${GHC_OS_SUFFIX}"

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

# Create cross-compilation environment with target libraries
create_cross_environment "${cross_target_platform}"

# Configure architecture-specific compile flags
get_arch_compile_flags "${target_arch}" "${OS_TYPE}" "${conda_target}"

# Configure GHC for cross-compilation
configure_ghc "${OS_TYPE}" "${ghc_target}" "${conda_host}" "${conda_target}"

# Fix host configuration to use x86_64, target cross
(
  settings_file="${SRC_DIR}"/hadrian/cfg/system.config
  perl -pi -e "s#${BUILD_PREFIX}/bin/##" "${settings_file}"
  perl -pi -e "s#(=\s+)(ar|clang|clang\+\+|llc|nm|opt|ranlib)\$#\$1${conda_target}-\$2#" "${settings_file}"
  perl -pi -e "s#(conf-gcc-linker-args-stage[12]\s*?=\s)#\$1-Wl,-L${CROSS_ENV_PATH}/lib -Wl,-rpath,${CROSS_ENV_PATH}/lib #" "${settings_file}"
  perl -pi -e "s#(conf-ld-linker-args-stage[12]\s*?=\s)#\$1-L${CROSS_ENV_PATH}/lib -rpath ${CROSS_ENV_PATH}/lib #" "${settings_file}"
  perl -pi -e "s#(settings-c-compiler-link-flags\s*?=\s)#\$1-Wl,-L${CROSS_ENV_PATH}/lib -Wl,-rpath,${CROSS_ENV_PATH}/lib #" "${settings_file}"
  perl -pi -e "s#(settings-ld-flags\s*?=\s)#\$1-L${CROSS_ENV_PATH}/lib -rpath ${CROSS_ENV_PATH}/lib #" "${settings_file}"

  perl -pi -e "s#(settings-clang-command\s*?=\s).*#\$1${conda_target}-clang#" "${settings_file}"
  perl -pi -e "s#(settings-merge-objects-command\s*?=\s).*#\$1${conda_target}-ld#" "${settings_file}"
)

# ---| Stage 1: Cross-compiler |---
perl -i -pe 's/finalStage = Stage2/finalStage = Stage1/' "${SRC_DIR}"/hadrian/src/UserSettings.hs

# Build hadrian with cabal (returns FULL path to binary)
hadrian_path=$(build_hadrian_cross "${GHC}" "${AR_STAGE0}" "${CC_STAGE0}" "${LD_STAGE0}")
echo "Using hadrian at: ${hadrian_path}"

# Verify hadrian works before proceeding
echo "Testing hadrian binary..."
"${hadrian_path}" --version || {
  echo "ERROR: Hadrian binary test failed!"
  exit 1
}

# Use FULL path in hadrian_build array - don't rely on PATH
hadrian_build=("${hadrian_path}" "-j${CPU_COUNT}" "--directory" "${SRC_DIR}")

# OPTIMIZATION: Build all stage1 executables in ONE hadrian invocation
# This allows Shake to properly track dependencies and avoid unnecessary rebuilds
run_and_log "stage1_executables" "${hadrian_build[@]}" \
  stage1:exe:ghc-bin \
  stage1:exe:ghc-pkg \
  stage1:exe:hsc2hs \
  --flavour=quick --docs=none --progress-info=none

# Build stage1:lib:ghc separately because we need to update GHC settings
(
  settings_file="${SRC_DIR}"/_build/stage0/lib/settings
  update_settings_link_flags "${settings_file}" "${conda_target}"
  run_and_log "stage1_lib" "${hadrian_build[@]}" stage1:lib:ghc --flavour=quick --docs=none --progress-info=none
  update_settings_link_flags "${settings_file}" "${conda_target}"
)

# Build binary dist - will reuse all previously built artifacts
run_and_log "binary-dist" "${hadrian_build[@]}" binary-dist --flavour=quick --freeze1 --docs=none --progress-info=none

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
    make install_bin install_lib install_docs install_man
  popd
else
  echo "Error: Could not find binary distribution directory"
  exit 1
fi

# Populate needed dynamic libraries
mkdir -p ${cross_prefix}/lib/private
cp "${CROSS_LIB_DIR}"/lib{gmp,iconv,ffi,ncurses,tinfo}*.so* "${cross_prefix}"/lib/private

# Correct CC/CXX
settings_file="$(find ${cross_prefix}/lib/ -name settings | head -1)"
if [[ -f "${settings_file}" ]]; then
  perl -pi -e "s#${host_arch}(-[^ \"]*)#${target_arch}\$1#g" "${settings_file}"
  perl -pi -e "s#(C compiler link flags\", \"[^\"]*)#\$1 -Wl,-L\\\$topdir/../../../lib -Wl,-rpath,\\\$topdir/../../../lib/private -Wl,-rpath,\\\$topdir/../../../lib#" "${settings_file}"
  perl -pi -e "s#(ld flags\", \"[^\"]*)#\$1 -L\\\$topdir/../../../lib -rpath \\\$topdir/../../../lib/private -rpath \\\$topdir/../../../lib#" "${settings_file}"
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
      rm -f "${bin}"
    fi
    perl -pi -e "s#${cross_prefix}#\\\${PREFIX}#g" "${conda_target}-${bin}"
  done
popd
