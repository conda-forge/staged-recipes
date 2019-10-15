#!/usr/bin/env bash
set -ex

export CFLAGS="${CFLAGS} -I${PREFIX}/include/unicode"
export CFLAGS="${CFLAGS} -DO_PATH=010000000"

# copy over missing files
cp -v "${RECIPE_DIR}/missing_kd.h" "${SRC_DIR}/src/basic/missing_kd.h"
cp -v "${RECIPE_DIR}/missing_loop.h" "${SRC_DIR}/src/basic/missing_loop.h"
cp -v "${RECIPE_DIR}/missing_time.h" "${SRC_DIR}/src/basic/missing_time.h"
cp -v "${RECIPE_DIR}/missing_types.h" "${SRC_DIR}/src/basic/missing_types.h"
cp -v "${RECIPE_DIR}/missing_ioctls.h" "${SRC_DIR}/src/basic/missing_ioctls.h"
cp -v "${RECIPE_DIR}/missing_inotify.h" "${SRC_DIR}/src/basic/missing_inotify.h"
cp -v "${RECIPE_DIR}/missing_neighbour.h" "${SRC_DIR}/src/basic/missing_neighbour.h"
cp -v "${RECIPE_DIR}/if_alg.h" "${SRC_DIR}/src/basic/linux/if_alg.h"
cp -v "${RECIPE_DIR}/securebits.h" "${SRC_DIR}/src/basic/linux/securebits.h"

mkdir -p build
pushd build
meson \
  --prefix="${PREFIX}" \
  --libdir="${PREFIX}/lib" \
  --buildtype=release \
  -Ddefault-dnssec=no \
  -Dblkid=true                 \
  -Ddefault-dnssec=no          \
  -Dfirstboot=false            \
  -Dinstall-tests=false        \
  -Dldconfig=false             \
  -Dsplit-usr=true             \
  -Dsysusers=false             \
  -Drpmmacrosdir=no            \
  -Dsmack=false \
  -Dseccomp=false \
  -Dselinux=false \
  -Defi=false \
  --strip \
  ..
meson install
meson test


