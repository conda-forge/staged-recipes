#!/usr/bin/env bash
set -ex
pkg-config --libs dolfinx

# not sure why this custom command isn't run by cmake
ffcx cpp/test/poisson.py -o cpp/test

cmake -DCMAKE_BUILD_TYPE=Developer -B build-test/ -S cpp/test/
cmake --build build-test
cd build-test

ctest -V --output-on-failure -R unittests
mpiexec -n 2 ctest -V --output-on-failure -R unittests
