#!/usr/bin/env bash
export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="-L/${PREFIX}/lib"
export PKG_CONFIG="${PREFIX}/bin/pkg-config"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
./configure --prefix="${PREFIX}" --with-python="${PYTHON}" \
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
  INCLUDE_PATH="${INCLUDE_PATH}" C_INCLUDE_PATH="${C_INCLUDE_PATH}"
  PKG_CONFIG="${PKG_CONFIG}" PKG_CONFIG_PATH="${PKG_CONFIG_PATH}" || \
  cat config.log
make
make check
make install
