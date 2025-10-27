#!/usr/bin/env bash
set -eu

_log_index=0

source "${RECIPE_DIR}"/building/common.sh

conda_host="${build_alias}"
conda_target="${triplet}"

host_arch="${conda_host%%-*}"
target_arch="${conda_target%%-*}"

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

CROSS_CFLAGS="-ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -isystem $PREFIX/include"
CROSS_CXXFLAGS="-ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -stdlib=libc++ -fvisibility-inlines-hidden -fmessage-length=0 -isystem $PREFIX/include"
CROSS_CPPFLAGS="-D_FORTIFY_SOURCE=2 -isystem $PREFIX/include -mmacosx-version-min=11.0"

# Configure and build GHC
AR_STAGE0=$(find "${BUILD_PREFIX}" -name llvm-ar | head -1)

SYSTEM_CONFIG=(
  --target="${target_alias}"
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
  
  ac_cv_path_ac_pt_CC="${BUILD_PREFIX}/bin/${conda_target}-clang"
  ac_cv_path_ac_pt_CXX="${BUILD_PREFIX}/bin/${conda_target}-clang++"
  ac_cv_prog_AR="${BUILD_PREFIX}/bin/${conda_target}-ar"
  ac_cv_prog_CC="${BUILD_PREFIX}/bin/${conda_target}-clang"
  ac_cv_prog_CXX="${BUILD_PREFIX}/bin/${conda_target}-clang++"
  ac_cv_prog_LD="${BUILD_PREFIX}/bin/${conda_target}-ld"
  ac_cv_prog_RANLIB="${BUILD_PREFIX}/bin/${conda_target}-ranlib"

  #AR="${BUILD_PREFIX}/bin/${conda_target}"-ar
  #AS="${BUILD_PREFIX}/bin/${conda_target}"-as
  #CC="${BUILD_PREFIX}/bin/${conda_target}"-clang
  #CXX="${BUILD_PREFIX}/bin/${conda_target}"-clang++
  #LD="${BUILD_PREFIX}/bin/${conda_target}"-ld
  #NM="${BUILD_PREFIX}/bin/${conda_target}"-nm
  #OBJDUMP="${BUILD_PREFIX}/bin/${conda_target}"-objdump
  #RANLIB="${BUILD_PREFIX}/bin/${conda_target}"-ranlib
  
  CPPFLAGS="${CROSS_CPPFLAGS}"
  CFLAGS="${CROSS_CFLAGS}"
  CXXFLAGS="${CROSS_CXXFLAGS}"
  LDFLAGS="-L${CROSS_ENV_PATH}/lib ${LDFLAGS:-}"
  AR_STAGE0="${AR_STAGE0}"
  CC_STAGE0="${CC_FOR_BUILD}"
  LD_STAGE0="${BUILD_PREFIX}/bin/${conda_host}-ld"
)

(
  run_and_log "configure" ./configure -v "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}" || { cat config.log; exit 1; }
)

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
settings_file=$(find "${CROSS_ENV_PATH}"/ghc-bootstrap/lib -name settings -type f | head -1)
perl -pi -e "s#[^ ]+/usr/lib/libiconv2.tbd##" "${settings_file}"

# ---| Stage 1: Cross-compiler |---

# Build hadrian with cabal outside script
pushd "${SRC_DIR}"/hadrian
  export CABFLAGS=(--enable-shared --enable-executable-dynamic -j)
  "${CABAL}" v2-build \
    --with-gcc="${CC_FOR_BUILD}" \
    --with-ar="${AR_STAGE0}" \
    --with-ld="${BUILD_PREFIX}/bin/${conda_host}-ld" \
    -j \
    clock \
    file-io \
    heaps \
    js-dgtable \
    js-flot \
    js-jquery \
    directory \
    os-string \
    splitmix \
    utf8-string \
    hashable \
    process \
    primitive \
    random \
    QuickCheck \
    unordered-containers \
    extra \
    Cabal-syntax \
    filepattern \
    Cabal \
    shake \
    hadrian \
    2>&1 | tee "${SRC_DIR}"/cabal-verbose.log
popd

if [[ $_cabal_exit_code -ne 0 ]]; then
  echo "=== Cabal build FAILED with exit code ${_cabal_exit_code} ==="
  exit 1
else
  echo "=== Cabal build SUCCEEDED ==="
fi

_hadrian_bin=$(find "${SRC_DIR}"/hadrian/dist-newstyle/build -name hadrian -type f | head -1)
_hadrian_build=("${_hadrian_bin}" "-j${CPU_COUNT}" "--directory" "${SRC_DIR}")

# Disable copy for cross-compilation - force building the cross binary
# Change the cross-compile copy condition to never match
perl -i -pe 's/finalStage = Stage2/finalStage = Stage1/' "${SRC_DIR}"/hadrian/src/UserSettings.hs
(
  export AR="${AR_STAGE0}"
  export AS="${BUILD_PREFIX}/bin/${conda_host}-as"
  export CC="${BUILD_PREFIX}/bin/${conda_host}-clang"
  export CXX="${BUILD_PREFIX}/bin/${conda_host}-clang++"
  export LD="${BUILD_PREFIX}/bin/${conda_host}-ld"
  
  ln -sf "${BUILD_PREFIX}/bin/${conda_host}-ar" "${BUILD_PREFIX}"/bin/ar
  ln -sf "${BUILD_PREFIX}/bin/${conda_host}-as" "${BUILD_PREFIX}"/bin/as
  ln -sf "${BUILD_PREFIX}/bin/${conda_host}-ld" "${BUILD_PREFIX}"/bin/ld
  
  "${_hadrian_build[@]}" stage1:exe:ghc-bin -VV --flavour=quickest --progress-info=unicorn
)
run_and_log "stage1_ghc-pkg" "${_hadrian_build[@]}" stage1:exe:ghc-pkg --flavour=quickest --docs=none --progress-info=none
run_and_log "stage1_hsc2hs"  "${_hadrian_build[@]}" stage1:exe:hsc2hs --flavour=quickest --docs=none --progress-info=none

"${SRC_DIR}"/_build/stage0/bin/arm64-apple-darwin20.0.0-ghc --version || { echo "Stage0 GHC failed to report version"; exit 1; }

# 9.12+: export DYLD_INSERT_LIBRARIES="${BUILD_PREFIX}/lib/libiconv.dylib:${BUILD_PREFIX}/lib/libffi.dylib${DYLD_INSERT_LIBRARIES:+:}${DYLD_INSERT_LIBRARIES:-}"
# export DYLD_INSERT_LIBRARIES="${BUILD_PREFIX}/lib/libiconv.dylib:${BUILD_PREFIX}/lib/libffi.dylib${DYLD_INSERT_LIBRARIES:+:}${DYLD_INSERT_LIBRARIES:-}"
run_and_log "stage1_lib" "${_hadrian_build[@]}" stage1:lib:ghc -VV --flavour=release --docs=none --progress-info=unicorn

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
      perl -pi -e "s#${cross_prefix}#\\\${PREFIX}#g" "${conda_target}-${bin}"
    fi
  done
popd
