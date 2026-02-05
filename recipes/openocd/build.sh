#!/usr/bin/env bash

set -euxo pipefail

if [[ ${target_platform} == win-* ]]; then
  export PREFIX=$(cygpath -u "$PREFIX")
  export BUILD_PREFIX=$(cygpath -u "$BUILD_PREFIX")
  export SRC_DIR=$(cygpath -u "$SRC_DIR")
fi

# Prepare jimtcl (conda feedstock does not provide header/library)
# We thus cannot use shared libs, plus feedstock seems unmaintained and stuck at 0.82
mkdir -p "${SRC_DIR}"/jimtcl
pushd "${SRC_DIR}"/jimtcl || exit 1
  ./configure \
    --prefix="${SRC_DIR}"/jimtcl-install \
    --disable-docs   # > "${SRC_DIR}"/_jimtcl_configure.log 2>&1
  make -j"${CPU_COUNT}"   # > "${SRC_DIR}"/_jimtcl_make.log 2>&1
  # This is not built on windows
  touch build-jim-ext
  make install

  export PATH="${SRC_DIR}"/jimtcl-install/bin:"${PATH}"
  export CFLAGS="-I${SRC_DIR}/jimtcl-install/include ${CFLAGS:-}"
  export LDFLAGS="-L${SRC_DIR}/jimtcl-install/lib ${LDFLAGS:-}"
popd || exit 1

PKG_CONFIG_PATH="${PKG_CONFIG_PATH}${PKG_CONFIG_PATH:+:}${SRC_DIR}/jimtcl-install/lib/pkgconfig"

if [[ ${target_platform} == win-* ]]; then
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${PREFIX}/Library/lib/pkgconfig"
  ACLOCAL_PATH="$(find "${BUILD_PREFIX}" -name pkg.m4 -print -quit)"
  export ACLOCAL_PATH
fi

export PKG_CONFIG_PATH

# Patching does not seem to work
sed -i 's/interp->currentScriptObj/interp->evalFrame->scriptObj/g' src/openocd.c
sed -i -E 's/calloc\(sizeof\(([^)]*)\),\s*([^)]*)\)/calloc(\2, sizeof(\1))/' \
  src/jtag/drivers/ulink.c \
  src/flash/nor/ambiqmicro.c \
  src/flash/nor/kinetis.c \
  src/flash/nor/msp432.c \
  src/flash/nor/max32xxx.c \
  src/flash/nor/xmc4xxx.c \
  src/flash/nor/stm32f2x.c \
  src/flash/nor/stellaris.c \
  src/target/arc_jtag.c \
  src/target/nds32.c

"${SRC_DIR}"/bootstrap nosubmodule  # > "${SRC_DIR}"/_bootstrap_openocd.log 2>&1

if [[ ${target_platform} == osx-* ]]; then
  export CFLAGS="${CFLAGS} -Wno-strict-prototypes -Wno-unused-but-set-variable -Wno-unused-but-set-parameter"
fi

mkdir -p "${SRC_DIR}/_conda-build"
pushd "${SRC_DIR}/_conda-build" || exit 1
  "${SRC_DIR}"/configure \
    --prefix="${PREFIX}" \
    --enable-shared \
    --disable-static \
    --disable-internal-jimtcl \
    --disable-internal-libjaylink   # > "${SRC_DIR}"/_configure_openocd.log 2>&1
  make -j"${CPU_COUNT}"   # > "${SRC_DIR}"/_make_openocd.log 2>&1
  make install
popd || exit 1

if [[ ${target_platform} != osx-* ]] && [[ ${target_platform} != linux-* ]]; then
  rm "${PREFIX}/share/openocd/scripts/target/1986*.cfg"                                          
  rm "${PREFIX}/share/openocd/scripts/target/*1879x*.cfg"                                         
fi
