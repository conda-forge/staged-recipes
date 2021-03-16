#!/bin/bash
set -e

BLD="build"
mkdir -p "$BLD"

cmake -H"$SRC_DIR/source" -B"$BLD" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_INSTALL_LIBDIR="$PREFIX/lib" \
    -DBUILD_SHARED_LIBS=BOTH \
    -Deccodes_DIR="$PREFIX/lib/cmake/eccodes" \
    -Dmi-cpptest_DIR="$PREFIX/lib/cmake/mi-cpptest" \
    -Dmi-programoptions_DIR="$PREFIX/lib/cmake/mi-programoptions" \
    -Dpybind11_DIR="$PREFIX/share/cmake/pybind11" \
    -DTEST_EXTRADATA_DIR="$SRC_DIR/testdata" \
    -DENABLE_FIMEX_VERSIONNUMBERED=NO \
    -DENABLE_ECCODES=YES \
    -DENABLE_LOG4CPP=YES \
    -DENABLE_FELT=YES \
    -DENABLE_FORTRAN=YES \
    -DENABLE_PRORADXML=NO \
    -DENABLE_FIMEX_OMP=YES \
    -DENABLE_PYTHON=YES

cmake --build "$BLD" --target "all"

export CTEST_OUTPUT_ON_FAILURE="1"
cmake --build "$BLD" --target "test"

cmake --build "$BLD" --target "install"
