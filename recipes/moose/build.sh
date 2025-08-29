#!/bin/bash
set -ex

# Clean and configure build using Meson
meson setup --wipe builddir \
  --prefix=$PREFIX \
  -Dbuildtype=release \
  -Duse_mpi=false \
  -Duse_hdf5=false

# Compile and install
meson compile -C builddir -j4
meson install -C builddir

