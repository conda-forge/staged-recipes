#!/usr/bin/env bash
set -ex

export CFLAGS="${CFLAGS} -I${PREFIX}/include/unicode"
export CFLAGS="${CFLAGS} -DO_PATH=010000000"

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
  ..
meson install
meson test


