#!/usr/bin/env bash
set -ex
pkg-config --libs dolfinx

cmake -DCMAKE_BUILD_TYPE=Developer -B build-test/ -S cpp/test/
cmake --build build-test
cd build-test

ctest -V --output-on-failure -R unittests
mpiexec -n 2 ctest -V --output-on-failure -R unittests
