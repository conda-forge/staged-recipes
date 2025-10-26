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
  ac_cv_prog_CC="${BUILD_PREFIX}/bin/${conda_target}-clang"
  ac_cv_path_ac_pt_CC="${BUILD_PREFIX}/bin/${conda_target}-clang"
  ac_cv_path_ac_pt_CXX="${BUILD_PREFIX}/bin/${conda_target}-clang++"
  LDFLAGS="-L${CROSS_ENV_PATH}/lib ${LDFLAGS:-}"
  AR_STAGE0="${AR_STAGE0}"
  CC_STAGE0="${CC_FOR_BUILD}"
  LD_STAGE0="${BUILD_PREFIX}/bin/${conda_host}-ld"
)

run_and_log "configure" ./configure -v "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}" || { cat config.log; exit 1; }

# Fix host configuration to use x86_64, target cross
settings_file="${SRC_DIR}"/hadrian/cfg/system.config
perl -pi -e "s#${BUILD_PREFIX}/bin/##" "${settings_file}"
perl -pi -e "s#(=\s+)(ar|clang|clang\+\+|llc|nm|objdump|opt|ranlib)\$#\$1${conda_target}-\$2#" "${settings_file}"
perl -pi -e "s#(system-ar\s*?=\s).*#\$1${AR_STAGE0}#" "${settings_file}"
perl -pi -e "s#(conf-gcc-linker-args-stage[12]\s*?=\s)#\$1-Wl,-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib #" "${settings_file}"
perl -pi -e "s#(conf-ld-linker-args-stage[12]\s*?=\s)#\$1-L${PREFIX}/lib -rpath ${PREFIX}/lib #" "${settings_file}"
perl -pi -e "s#(settings-c-compiler-link-flags\s*?=\s)#\$1-Wl,-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib #" "${settings_file}"
perl -pi -e "s#(settings-ld-flags\s*?=\s)#\$1-L${PREFIX}/lib -rpath ${PREFIX}/lib #" "${settings_file}"

cat "${settings_file}"

_hadrian_build=("${SRC_DIR}"/hadrian/build "-j${CPU_COUNT}")

# Bug in ghc-bootstrap for libiconv2
perl -pi -e "s#[^ ]+/usr/lib/libiconv2.tbd##" "${osx_64_env}"/ghc-bootstrap/lib/ghc-"${PKG_VERSION}"/lib/settings

# This will not generate ghc-toolchain-bin or the .ghc-toolchain (possibly due to x-platform)
run_and_log "ghc-configure" ./configure "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}"

# Build hadrian with cabal outside script
pushd "${SRC_DIR}"/hadrian
  export CABFLAGS=(--enable-shared --enable-executable-dynamic -j)
  "${CABAL}" v2-build \
    --with-gcc="${CC_FOR_BUILD}" \
    --with-ar="${AR}" \
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

# ---| Stage 1: Cross-compiler |---

pushd "${SRC_DIR}"/hadrian
  export CABFLAGS=(--enable-shared --enable-executable-dynamic -j)
  "${CABAL}" v2-build \
    --with-gcc="${CC_FOR_BUILD}" \
    --with-ar="${AR}" \
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
    _cabal_exit_code=${PIPESTATUS[0]}
popd

# Disable copy for cross-compilation - force building the cross binary
# Change the cross-compile copy condition to never match
perl -i -pe 's/\(True, s\) \| s > stage0InTree ->/\(False, s\) | s > stage0InTree \&\& False ->/' "${SRC_DIR}"/hadrian/src/Rules/Program.hs
"${_hadrian_build[@]}" stage1:exe:ghc-bin -VV --flavour=quickest --progress-info=unicorn
run_and_log "stage1_ghc-pkg" "${_hadrian_build[@]}" stage1:exe:ghc-pkg --flavour=quickest --docs=none --progress-info=none
run_and_log "stage1_hsc2hs"  "${_hadrian_build[@]}" stage1:exe:hsc2hs --flavour=quickest --docs=none --progress-info=none

"${SRC_DIR}"/_build/stage0/bin/arm64-apple-darwin20.0.0-ghc --version || { echo "Stage0 GHC failed to report version"; exit 1; }

# 9.12+: export DYLD_INSERT_LIBRARIES="${BUILD_PREFIX}/lib/libiconv.dylib:${BUILD_PREFIX}/lib/libffi.dylib${DYLD_INSERT_LIBRARIES:+:}${DYLD_INSERT_LIBRARIES:-}"
# export DYLD_INSERT_LIBRARIES="${BUILD_PREFIX}/lib/libiconv.dylib:${BUILD_PREFIX}/lib/libffi.dylib${DYLD_INSERT_LIBRARIES:+:}${DYLD_INSERT_LIBRARIES:-}"
run_and_log "stage1_lib" "${_hadrian_build[@]}" stage1:lib:ghc -VV --flavour=release --docs=none --progress-info=unicorn
run_and_log "stage2_exe" "${_hadrian_build[@]}" stage2:exe:ghc-bin --flavour=release --freeze1 --docs=none --progress-info=none
run_and_log "build_all" "${_hadrian_build[@]}" --flavour=release --freeze1 --freeze2 --docs=no-sphinx-pdfs --progress-info=none
run_and_log "install" "${_hadrian_build[@]}" install --prefix="${PREFIX}" --flavour=release --freeze1 --freeze2 --docs=none --progress-info=none || true

# Create links of aarch64-conda-linux-gnu-xxx to xxx
pushd "${PREFIX}"/bin
  for bin in arm64-apple-darwin20.0.0-*; do
    ln -s "${bin}" "${bin#arm64-apple-darwin20.0.0-}"
  done
popd

pushd "${PREFIX}"/lib
  if [[ -d arm64-apple-darwin20.0.0-ghc-"${PKG_VERSION}" ]]; then
    mv arm64-apple-darwin20.0.0-ghc-"${PKG_VERSION}" ghc-"${PKG_VERSION}"
    ln -s ghc-"${PKG_VERSION}" arm64-apple-darwin20.0.0-ghc-"${PKG_VERSION}"
  fi
popd
