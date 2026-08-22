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
# The shared library is libhashhp.so on Linux and libhashhp.dylib on
# macOS (dlopen accepts the .so name for a Mach-O dylib, so a plain
# rename keeps the front-end working on both platforms).
if [ -f build-conda/libhashhp.so ]; then
    NATIVE_LIB=build-conda/libhashhp.so
elif [ -f build-conda/libhashhp.dylib ]; then
    NATIVE_LIB=build-conda/libhashhp.dylib
else
    echo "libhashhp shared library not found in build-conda" >&2
    exit 1
fi
mkdir -p "${SP_DIR}/cnchash/lib"
cp "${NATIVE_LIB}" "${SP_DIR}/cnchash/lib/libhashhp.so"
