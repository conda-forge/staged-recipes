#!/bin/bash
set -euxo pipefail

# One shared library per datatype (libkissfft-float, libkissfft-double); they
# share the headers and CMake package, upstream supports installing several
# datatypes side by side.
for datatype in float double; do
  cmake -G Ninja -B "_build_${datatype}" -S . ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_INCLUDEDIR=include \
    -DCMAKE_INSTALL_BINDIR=bin \
    -DKISSFFT_DATATYPE="${datatype}" \
    -DKISSFFT_STATIC=OFF \
    -DKISSFFT_OPENMP=OFF \
    -DKISSFFT_PKGCONFIG=ON \
    -DKISSFFT_TOOLS=OFF \
    -DKISSFFT_TEST=OFF
  cmake --build "_build_${datatype}" --parallel "${CPU_COUNT}"
  cmake --install "_build_${datatype}"
done
