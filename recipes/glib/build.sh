#!/usr/bin/env bash
export PKG_CONFIG="${PREFIX}/bin/pkg-config"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
./configure --prefix="${PREFIX}" --with-python="${PYTHON}" \
  PKG_CONFIG="${PKG_CONFIG}" PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
make
make check
make install
