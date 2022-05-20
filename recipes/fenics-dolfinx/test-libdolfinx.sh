#!/usr/bin/env bash
set -ex
pkg-config --libs libdolfinx

cmake  --build-dir build-test/ -S cpp/test/
cmake --build build-test
cd build-test
ctest -V --output-on-failure -R unittests
mpiexec -n 2 ctest -V --output-on-failure -R unittests
