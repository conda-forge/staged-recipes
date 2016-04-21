#!/usr/bin/env bash
export CFLAGS="-O2"
export CXXFLAGS="-O2"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="-L/${PREFIX}/lib"
export PKG_CONFIG="${PREFIX}/bin/pkg-config"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
./configure --prefix="${PREFIX}" --with-python="${PYTHON}" \
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
  PKG_CONFIG="${PKG_CONFIG}" PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
make
make check
make install
