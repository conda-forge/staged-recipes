#!/usr/bin/env bash

set -eu -x -o pipefail

export OMP_NUM_THREADS=2

export OMPI_MCA_plm=^rsh

cmake    \
    -S ${PREFIX}/share/heffte/testing  \
    -B build_test                      \
    -DBUILD_SHARED_LIBS=ON             \
    -DCMAKE_VERBOSE_MAKEFILE=ON

cmake --build build_test
ctest --test-dir build_test --output-on-failure
