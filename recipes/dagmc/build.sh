#!/usr/bin/env bash

# Install DAGMC
cmake -DMOAB_DIR="${PREFIX}" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}"
      -DBUILD_STATIC_LIBS=OFF
      -DBUILD_RPATH=OFF
make -j "${CPU_COUNT}"
make install
