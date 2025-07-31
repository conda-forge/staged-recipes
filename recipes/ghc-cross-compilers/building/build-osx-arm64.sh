#!/usr/bin/env bash
set -eu

_log_index=0

source "${RECIPE_DIR}"/building/common.sh

_build_alias=${build_alias}
_build_version="${build_alias##*darwin}"
_host_alias=${host_alias}
_host_version="${host_alias##*darwin}"
_ghc_host="x86_64-apple-darwin"

export build_alias="${_ghc_host}"
export host_alias="${_ghc_host}"
export BUILD=${build_alias}
export HOST=${host_alias}

# Update cabal package database
run_and_log "cabal-update" cabal v2-update

# Configure and build GHC
SYSTEM_CONFIG=(
  --prefix="${PREFIX}"
)

if [[ "${_build_alias}" != "${_host_alias}" ]]; then
  SYSTEM_CONFIG+=(
    --build="${_build_alias}"
    --host="${_build_alias}"
    --target="${_host_alias}"
  )
fi

CONFIGURE_ARGS=(
  --disable-numa
  --enable-ignore-build-platform-mismatch=yes
  # This creates conflicts downstream: --enable-ghc-toolchain=yes
  --with-system-libffi=yes
  --with-curses-includes="${BUILD_PREFIX}"/include
  --with-curses-libraries="${BUILD_PREFIX}"/lib
  --with-ffi-includes="${BUILD_PREFIX}"/include
  --with-ffi-libraries="${BUILD_PREFIX}"/lib
  --with-gmp-includes="${BUILD_PREFIX}"/include
  --with-gmp-libraries="${BUILD_PREFIX}"/lib
  --with-iconv-includes="${BUILD_PREFIX}"/include
  --with-iconv-libraries="${BUILD_PREFIX}"/lib
)

export build_alias=${_build_alias}
export host_alias=${_host_alias}
export BUILD=${build_alias}
export HOST=${host_alias}

# This will not generate ghc-toolchain-bin or the .ghc-toolchain (possibly due to x-platform)
MergeCmdObj=${MergeCmdObj:-${CONDA_TOOLCHAIN_BUILD}-ld} \
AR=${CONDA_TOOLCHAIN_BUILD}-ar \
AS=${CONDA_TOOLCHAIN_BUILD}-as \
CC=${CC_FOR_BUILD} \
CXX=${CXX_FOR_BUILD} \
NM=${CONDA_TOOLCHAIN_BUILD}-nm \
RANLIB=${CONDA_TOOLCHAIN_BUILD}-ranlib \
LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX/} \
LDFLAGS_LD=${LDFLAGS_LD//$PREFIX/$BUILD_PREFIX/} \
run_and_log "ghc-configure" bash configure "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}"

perl -pi -e 's#($ENV{BUILD_PREFIX}|$ENV{PREFIX})/bin/##' "${SRC_DIR}"/hadrian/cfg/default.target
if [[ "${_build_alias}" != "${_host_alias}" ]]; then
  perl -pi -e 's#"--target=[\w-]+"#"--target=aarch64-apple-darwin"#'  "${SRC_DIR}"/hadrian/cfg/default.target
  perl -pi -e 's#"--target=[\w-]+"#"--target=x86_64-apple-darwin"#'  "${SRC_DIR}"/hadrian/cfg/default.host.target
  perl -pi -e 's/aarch64/x86_64/;s/ArchAArch64/ArchX86_64/' "${SRC_DIR}"/hadrian/cfg/default.host.target
fi

_hadrian_build=("${SRC_DIR}"/hadrian/build "-j${CPU_COUNT}")

# Should be corrected in ghc-bootstrap
#settings_file=$(find "${BUILD_PREFIX}"/ghc-bootstrap -name settings | head -1)
#if [[ -n "${SDKROOT}" ]]; then
#  perl -i -pe 's#("C compiler link flags", ")([^"]*)"#\1\2 -L$ENV{SDKROOT}/usr/lib"#g' "${settings_file}"
#fi

"${_hadrian_build[@]}" stage1:exe:ghc-bin -V --flavour=release --progress-info=unicorn

"${SRC_DIR}"/_build/stage0/bin/arm64-apple-darwin20.0.0-ghc --version || { echo "Stage0 GHC failed to report version"; exit 1; }

CONFIGURE_ARGS=(
  --prefix="${PREFIX}"
  --disable-numa
  --enable-ignore-build-platform-mismatch=yes
  # This creates conflicts downstream: --enable-ghc-toolchain=yes
  --with-system-libffi=yes
  --with-curses-includes="${PREFIX}"/include
  --with-curses-libraries="${PREFIX}"/lib
  --with-ffi-includes="${PREFIX}"/include
  --with-ffi-libraries="${PREFIX}"/lib
  --with-gmp-includes="${PREFIX}"/include
  --with-gmp-libraries="${PREFIX}"/lib
  --with-iconv-includes="${PREFIX}"/include
  --with-iconv-libraries="${PREFIX}"/lib
)

# This will not generate ghc-toolchain-bin or the .ghc-toolchain (possibly due to x-platform)
run_and_log "ghc-configure" bash configure "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}"
perl -pi -e 's#($ENV{BUILD_PREFIX}|$ENV{PREFIX})/bin/##' "${SRC_DIR}"/hadrian/cfg/default.target
if [[ "${_build_alias}" != "${_host_alias}" ]]; then
  perl -pi -e 's#"--target=[\w-]+"#"--target=aarch64-apple-darwin"#'  "${SRC_DIR}"/hadrian/cfg/default.target
  perl -pi -e 's#"--target=[\w-]+"#"--target=x86_64-apple-darwin"#'  "${SRC_DIR}"/hadrian/cfg/default.host.target
  perl -pi -e 's/aarch64/x86_64/;s/ArchAArch64/ArchX86_64/' "${SRC_DIR}"/hadrian/cfg/default.host.target
fi

export DYLD_INSERT_LIBRARIES="${BUILD_PREFIX}/lib/libiconv.dylib:${BUILD_PREFIX}/lib/libffi.dylib${DYLD_INSERT_LIBRARIES:+:}${DYLD_INSERT_LIBRARIES:-}"
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
