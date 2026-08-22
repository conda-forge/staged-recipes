#!/bin/bash
set -eux

# Build the Modern Fortran/OpenMP core (libhashhp) with the conda toolchain.
cmake -S . -B build-conda \
  -DCMAKE_BUILD_TYPE=Release \
  -DCNCHASH_BUILD_TESTS=OFF
cmake --build build-conda -j "${CPU_COUNT:-4}"

# Install the Python front-end.
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv

# Ship the native library in the installed package layout:
# cnchash/backend/fortran_backend.py looks for ../lib/libhashhp.so
# relative to itself, i.e. <site-packages>/cnchash/lib/libhashhp.so.
mkdir -p "${SP_DIR}/cnchash/lib"
cp build-conda/libhashhp.so "${SP_DIR}/cnchash/lib/libhashhp.so"
