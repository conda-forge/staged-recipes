#!/usr/bin/env bash
set -eu

_log_index=0

source "${RECIPE_DIR}"/building/common.sh

# Detect platform configuration
detect_platform_config "${target_platform}"

conda_host="${build_alias}"
conda_target="${triplet}"

host_arch="${conda_host%%-*}"
target_arch="${conda_target%%-*}"

# macOS uses pattern substitution to normalize darwin version
ghc_host="${conda_host/darwin*/darwin}"
ghc_target="${conda_target/darwin*/darwin}"

export build_alias="${conda_host}"
export host_alias="${conda_host}"
export target_alias="${conda_target}"
export host_platform="${build_platform}"

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
  perl -pi -e "s#(=\s+)(ar|clang|clang\+\+|llc|nm|objdump|opt|ranlib)\$#\$1${conda_target}-\$2#" "${settings_file}"
  perl -pi -e "s#(system-ar\s*?=\s).*#\$1${AR_STAGE0}#" "${settings_file}"
  perl -pi -e "s#(conf-cc-args-stage0\s*?=\s).*#\$1--target=${ghc_host}#" "${settings_file}"
  perl -pi -e "s#(conf-gcc-linker-args-stage0\s*?=\s).*#\$1--target=${ghc_host}#" "${settings_file}"
  perl -pi -e "s#(conf-gcc-linker-args-stage[12]\s*?=\s)#\$1-Wl,-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib #" "${settings_file}"
  perl -pi -e "s#(conf-ld-linker-args-stage[12]\s*?=\s)#\$1-L${PREFIX}/lib -rpath ${PREFIX}/lib #" "${settings_file}"
  perl -pi -e "s#(settings-c-compiler-link-flags\s*?=\s)#\$1-Wl,-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib #" "${settings_file}"
  perl -pi -e "s#(settings-ld-flags\s*?=\s)#\$1-L${PREFIX}/lib -rpath ${PREFIX}/lib #" "${settings_file}"
  perl -pi -e "s#(settings.*?command\s*?=\s*)${conda_host}#\$1${conda_target}#" "${settings_file}"

  perl -pi -e "s#${conda_target}-(objdump)#\$1#" "${settings_file}"
  cat "${settings_file}"
)

# Bug in ghc-bootstrap for libiconv2
(
  settings_file=$(find "${CROSS_ENV_PATH}"/ghc-bootstrap/lib -name settings -type f | head -1)
  perl -pi -e "s#[^ ]+/usr/lib/libiconv2.tbd##" "${settings_file}"
)

# ---| Stage 1: Cross-compiler |---

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

# Disable copy for cross-compilation - force building the cross binary
# Change the cross-compile copy condition to never match
perl -i -pe 's/finalStage = Stage2/finalStage = Stage1/' "${SRC_DIR}"/hadrian/src/UserSettings.hs
export AR="${AR_STAGE0}"
export AS="${BUILD_PREFIX}/bin/${conda_host}-as"
export CC="${BUILD_PREFIX}/bin/${conda_host}-clang"
export CXX="${BUILD_PREFIX}/bin/${conda_host}-clang++"
export LD="${BUILD_PREFIX}/bin/${conda_host}-ld"
export LDFLAGS="-L${CROSS_ENV_PATH}/ ${LDFLAGS}"

ln -sf "${BUILD_PREFIX}/bin/${conda_host}-ar" "${BUILD_PREFIX}"/bin/ar
ln -sf "${BUILD_PREFIX}/bin/${conda_host}-as" "${BUILD_PREFIX}"/bin/as
ln -sf "${BUILD_PREFIX}/bin/${conda_host}-ld" "${BUILD_PREFIX}"/bin/ld

# OPTIMIZATION: Build all stage1 executables in ONE hadrian invocation
# This allows Shake to properly track dependencies and avoid unnecessary rebuilds
run_and_log "stage1_executables" "${hadrian_build[@]}" \
  stage1:exe:ghc-bin \
  stage1:exe:ghc-pkg \
  stage1:exe:hsc2hs \
  --flavour=quick --docs=none --progress-info=none

# Build stage1:lib:ghc separately with settings adjustment
(
  settings_file="${SRC_DIR}"/_build/stage0/lib/settings
  perl -pi -e "s#(C compiler link flags\", \"[^\"]*)#\$1 -Wl,-L${CROSS_ENV_PATH}/lib#" "${settings_file}"
  perl -pi -e "s#(ld flags\", \"[^\"]*)#\$1 -L${CROSS_ENV_PATH}/lib#" "${settings_file}"
  run_and_log "stage1_lib" "${hadrian_build[@]}" stage1:lib:ghc --flavour=quick --docs=none --progress-info=none
)

# Build binary dist - will reuse all previously built artifacts
run_and_log "bindist" "${hadrian_build[@]}" binary-dist --flavour=quick --docs=none --progress-info=none

# Now manually install from the bindist with correct configure arguments
cross_prefix="${SRC_DIR}"/cross_install && mkdir -p "${SRC_DIR}"/cross_install
bindist_dir=$(find "${SRC_DIR}"/_build/bindist -name "*ghc-${PKG_VERSION}-*" -type d | head -1)
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

# Correct CC/CXX
settings_file="$(find ${cross_prefix}/lib/ -name settings | head -1)"
if [[ -f "${settings_file}" ]]; then
  perl -pi -e "s#${conda_host}#${conda_target}#g" "${settings_file}"
  perl -pi -e "s#(C compiler link flags\", \"[^\"]*)#\$1 -Wl,-L\\\$topdir/private -Wl,-L\\\$topdir/../../../lib -Wl,-rpath,\\\$topdir/private -Wl,-rpath,\\\$topdir/../../../lib#" "${settings_file}"
  perl -pi -e "s#(ld flags\", \"[^\"]*)#\$1 -L\\\$topdir/private -L\\\$topdir/../../../lib -rpath \\\$topdir/private -rpath \\\$topdir/../../../lib#" "${settings_file}"
  perl -pi -e "s#\"[\$/\w]*?-(clang|clang\+\+|ld|ranlib|llc|opt)\"#\"${conda_target}-\$1\"#" "${settings_file}"
  perl -pi -e "s#\"[^\"]*?(llvm-ar)\"#\"\$1\"#" "${settings_file}"
  cat "${settings_file}"
else
  echo "Error: Could not find settins file"
  exit 1
fi

# Populate needed dynamic libraries
private_lib=$(dirname ${settings_file}) && mkdir -p "${private_lib}"
cp "${CROSS_LIB_DIR}"/lib{gmp,iconv,ffi,ncurses,tinfo}*.dylib* "${private_lib}"

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

# A bug? numeric in the triplet mangles with version string
find "${cross_prefix}"/lib/${triplet}-ghc-${PKG_VERSION}/bin -name "*${PKG_VERSION}.0.0*" | while read -r mangled; do
  folder=$(dirname ${mangled})
  file=$(basename ${mangled})
  
  unmangled=$(echo "${file}" | perl -pe "s#(darwin\d{2})(-.*?)(${PKG_VERSION})(\.[0-9]\.[0-9])-(.+)#\$1\$4\$2\$5-\$3#")
  mv "${folder}"/"${file}" "${folder}"/"${unmangled}"
done

