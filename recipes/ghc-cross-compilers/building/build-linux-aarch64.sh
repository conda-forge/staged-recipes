#!/usr/bin/env bash
set -eu

_log_index=0

source "${RECIPE_DIR}"/building/common.sh

_build_alias=${build_alias}
_host_alias=${host_alias}
_ghc_host="x86_64-conda-linux-gnu"

export build_alias="${_ghc_host}"
export host_alias="${_ghc_host}"
export BUILD=${build_alias}
export HOST=${host_alias}

# Update cabal package database
run_and_log "cabal-update" cabal v2-update

_hadrian_build=("${SRC_DIR}"/hadrian/build "-j${CPU_COUNT}")

# Configure and build GHC
SYSTEM_CONFIG=(
  --build="x86_64-conda-linux-gnu"
  --host="x86_64-conda-linux-gnu"
  --target="aarch64-conda-linux-gnu"
  --prefix="${PREFIX}"
)

CONFIGURE_ARGS=(
  --enable-ignore-build-platform-mismatch=yes
  --disable-numa
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

# env
# cat $(find ${BUILD_PREFIX} -name settings -type f)

MergeObjsCmd=aarch64-conda-linux-gnu-ld.gold \
AR=aarch64-conda-linux-gnu-ar \
AS=aarch64-conda-linux-gnu-as \
CC=aarch64-conda-linux-gnu-clang \
CXX=aarch64-conda-linux-gnu-clang++ \
NM=aarch64-conda-linux-gnu-nm \
RANLIB=aarch64-conda-linux-gnu-ranlib \
run_and_log "ghc-configure" bash configure "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}"

# Fix host configuration to use x86_64, target aarch64
perl -pi -e 's#"--target=[\w-]+"#"--target=x86_64-unknown-linux","--sysroot=$ENV{BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot"#'  "${SRC_DIR}"/hadrian/cfg/default.host.target
perl -pi -e 's/aarch64/x86_64/;s/ArchAArch64/ArchX86_64/' "${SRC_DIR}"/hadrian/cfg/default.host.target
perl -pi -e 's#"--target=[\w-]+"#"--target=aarch64-unknown-linux","--sysroot=$ENV{BUILD_PREFIX}/aarch64-conda-linux-gnu/sysroot"#'  "${SRC_DIR}"/hadrian/cfg/default.target

run_and_log "stage1_exe" "${_hadrian_build[@]}" stage1:exe:ghc-bin --flavour=release --docs=none --progress-info=none
perl -pi -e 's#($ENV{BUILD_PREFIX}|$ENV{PREFIX})/bin/##' "${SRC_DIR}"/_build/stage0/lib/settings

# GHC build ghc-pkg with '-fno-use-rpaths' but it requires libiconv.so.2
# _build/stage1/bin/ghc-pkg: error while loading shared libraries: libiconv.so.2
export LD_PRELOAD="${BUILD_PREFIX}/lib/libiconv.so.2 ${BUILD_PREFIX}/lib/libgmp.so.10 ${BUILD_PREFIX}/lib/libffi.so.8 ${BUILD_PREFIX}/lib/libtinfow.so.6 ${BUILD_PREFIX}/lib/libtinfo.so.6 ${LD_PRELOAD:-}"
run_and_log "bindist" "${_hadrian_build[@]}" binary-dist --prefix="${PREFIX}" --flavour=release --docs=none --progress-info=none

# Now manually install from the bindist with correct configure arguments
BINDIST_DIR=$(find "${SRC_DIR}"/_build/bindist -name "ghc-*-aarch64-conda-linux-gnu" -type d | head -1)
if [[ -n "${BINDIST_DIR}" ]]; then
    pushd "${BINDIST_DIR}"
    
    # Configure the binary distribution with proper cross-compilation settings
    ./configure --prefix="${PREFIX}" --build=x86_64-conda-linux-gnu --host=x86_64-conda-linux-gnu --target=aarch64-conda-linux-gnu
    
    # Install
    make install
    
    popd
else
    echo "Error: Could not find binary distribution directory"
    exit 1
fi

# Create links of aarch64-conda-linux-gnu-xxx to xxx
pushd "${PREFIX}"/bin
  for bin in aarch64-conda-linux-gnu-*; do
    ln -s "${bin}" "${bin#aarch64-conda-linux-gnu-}"
  done
popd

if [[ -d "${PREFIX}"/lib/aarch64-conda-linux-gnu-ghc-"${PKG_VERSION}" ]]; then
  # $PREFIX/lib/aarch64-conda-linux-gnu-ghc-9.12.2 -> $PREFIX/lib/ghc-9.12.2
  mv "${PREFIX}"/lib/aarch64-conda-linux-gnu-ghc-"${PKG_VERSION}" "${PREFIX}"/lib/ghc-"${PKG_VERSION}"
  ln -sf "${PREFIX}"/lib/ghc-"${PKG_VERSION}" "${PREFIX}"/lib/aarch64-conda-linux-gnu-ghc-"${PKG_VERSION}"
fi
