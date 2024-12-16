#!/usr/bin/env bash

set -euxo pipefail

# Prepare jimtcl (conda feedstock does not provide header/library)
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
  export PKG_CONFIG_PATH="${SRC_DIR}/jimtcl-install/lib/pkgconfig:${PREFIX}/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
popd || exit 1

if [[ ${target_platform} == win-* ]]; then
  export ACLOCAL_PATH="${ACLOCAL_PATH}${ACLOCAL_PATH:+:}${BUILD_PREFIX}/Library/mingw-w64/share/aclocal"
  type ${BUILD_PREFIX}/Library/mingw-w64/share/aclocal/pkg.m4
  echo "Setting ACLOCAL_PATH to: ${ACLOCAL_PATH}"
fi

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
