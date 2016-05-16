#!/usr/bin/env bash
set -e

SRC_ROOT="$(pwd)"

# test code
mkdir -p build-test
cd build-test
cmake -Dgtest_build_tests=ON -DPYTHON_EXECUTABLE=${PYTHON} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" "${SRC_ROOT}"
make
make test  # tests are Py 2k only
cd "${SRC_ROOT}"

# make code
mkdir -p build-code
cd build-code
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DBUILD_SHARED_LIBS=ON "${SRC_ROOT}"
make
# no make install, must proceed manually
cp -a "${SRC_ROOT}/include/gtest" "${PREFIX}/include"
cp -a libgtest_main.so libgtest.so "${PREFIX}/lib/"