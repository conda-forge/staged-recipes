#!/usr/bin/env bash
set -eu

_log_index=0

source "${RECIPE_DIR}"/building/common.sh

conda_host="${build_alias}"
conda_target="${host_alias}"

host_arch="${conda_host%%-*}"
target_arch="${conda_target%%-*}"

ghc_host="${conda_host/darwin*/darwin}"
ghc_target="${conda_target/darwin*/darwin}"

export build_alias="${conda_host}"
export host_alias="${conda_host}"
export target_alias="${conda_target}"
export host_platform="${build_platform}"

# Create environment and get library paths
echo "Creating environment for cross-compilation libraries..."
conda create -y \
    -n osx64_env \
    --platform osx-64 \
    -c conda-forge \
    cabal==3.10.3.0 \
    ghc-bootstrap=="${PKG_VERSION}"

osx_64_env=$(conda info --envs | grep osx64_env | awk '{print $2}')
ghc_path="${osx_64_env}"/ghc-bootstrap/bin
export GHC="${ghc_path}"/ghc

"${ghc_path}"/ghc-pkg recache

export CABAL="${osx_64_env}"/bin/cabal
export CABAL_DIR="${SRC_DIR}"/.cabal

mkdir -p "${CABAL_DIR}" && "${CABAL}" user-config init
run_and_log "cabal-update" "${CABAL}" v2-update

# Configure and build GHC
echo $(find "${BUILD_PREFIX}" -name llvm-ar)
AR=$(find "${BUILD_PREFIX}" -name llvm-ar | head -1)
export AR

SYSTEM_CONFIG=(
  --target="${target_alias}"
  --prefix="${PREFIX}"
)

CONFIGURE_ARGS=(
  --with-system-libffi=yes
  --with-curses-includes="${PREFIX}"/include
  --with-curses-libraries="${PREFIX}"/lib
  --with-ffi-includes="${PREFIX}"/include
  --with-ffi-libraries="${PREFIX}"/lib
  --with-gmp-includes="${PREFIX}"/include
  --with-gmp-libraries="${PREFIX}"/lib
  --with-iconv-includes="${PREFIX}"/include
  --with-iconv-libraries="${PREFIX}"/lib
  ac_cv_lib_ffi_ffi_call=yes
  AR="${AR}"
  LDFLAGS="-L${PREFIX}/lib ${LDFLAGS:-}"
  CC_STAGE0="${CC_FOR_BUILD}"
)

run_and_log "configure" ./configure -v "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}" || { cat config.log; exit 1; }

# Fix host configuration to use x86_64, target cross
settings_file="${SRC_DIR}"/hadrian/cfg/system.config
perl -pi -e "s#${BUILD_PREFIX}/bin/##" "${settings_file}"
perl -pi -e "s#(=\s+)(ar|clang|clang\+\+|llc|nm|objdump|opt|ranlib)\$#\$1${conda_target}-\$2#" "${settings_file}"
perl -pi -e "s#(system-ar\s*?=\s+).*#\$1${AR}#" "${settings_file}"
perl -pi -e "s#(conf-gcc-linker-args-stage[12]\s*?=\s+)#\$1-Wl,-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib#" "${settings_file}"
perl -pi -e "s#(conf-ld-linker-args-stage[12]\s*?=\s+)#\$1-L${PREFIX}/lib -rpath ${PREFIX}/lib#" "${settings_file}"
perl -pi -e "s#(settings-c-compiler-link-flags\s*?=\s+)#\$1-Wl,-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib#" "${settings_file}"
perl -pi -e "s#(settings-ld-flags\s*?=\s+)#\$1-L${PREFIX}/lib -rpath ${PREFIX}/lib#" "${settings_file}"

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
