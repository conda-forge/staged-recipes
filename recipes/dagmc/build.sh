#!/usr/bin/env bash

# Install DAGMC
cmake -DMOAB_DIR="${PREFIX}" \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}"
make -j "${CPU_COUNT}"
make install
