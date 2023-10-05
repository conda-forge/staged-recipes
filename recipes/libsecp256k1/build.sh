#!/usr/bin/env bash
set -ex

# Prepare post-install tests
TEST_DIR="${RECIPE_DIR}/shared_standalone_tests"
cp ${SRC_DIR}/src/tests.c ${TEST_DIR}/src
cp ${SRC_DIR}/src/tests_exhaustive.c ${TEST_DIR}/src
cp ${SRC_DIR}/src/secp256k1.c ${TEST_DIR}/src
(cd ${SRC_DIR}; tar cf - include | (cd ${TEST_DIR}; tar xf -))
(cd ${SRC_DIR}; tar cf - contrib | (cd ${TEST_DIR}; tar xf -))
(cd ${SRC_DIR}; tar cf - cmake | (cd ${TEST_DIR}/src; tar xf -))
(cd ${SRC_DIR}/src; tar cf - *.h modules/*/*.h wycheproof/*.h | (cd ${TEST_DIR}/src; tar xf -))

# Build environment
export SECP256K1_BUILD_SHARED_LIBS="ON"
export SECP256K1_INSTALL_HEADERS="OFF"
export SECP256K1_INSTALL="ON"

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}

# Build & Install
cd ${BUILD_DIR}
  cmake ${CMAKE_ARGS} \
      -S ${SRC_DIR} \
      -B . \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_PREFIX_PATH=${PREFIX} \
      -D CMAKE_INSTALL_PREFIX=${PREFIX} \
      -D SECP256K1_ENABLE_MODULE_RECOVERY=ON \
      -D BUILD_SHARED_LIBS=${SECP256K1_BUILD_SHARED_LIBS} \
      -D SECP256K1_INSTALL_HEADERS=${SECP256K1_INSTALL_HEADERS} \
      -D SECP256K1_INSTALL=${SECP256K1_INSTALL} \
      -D SECP256K1_BUILD_BENCHMARKS=OFF \
      -D SECP256K1_BUILD_TESTS=ON \
      -D SECP256K1_BUILD_EXHAUSTIVE_TESTS=OFF

  echo "Installing Library" >&2
  echo "   PKG_NAME=${PKG_NAME}" >&2
  echo "   SECP256K1_BUILD_SHARED_LIBS=${SECP256K1_BUILD_SHARED_LIBS}" >&2
  echo "   SECP256K1_INSTALL_HEADERS=${SECP256K1_INSTALL_HEADERS}" >&2
  echo "   SECP256K1_INSTALL=${SECP256K1_INSTALL}" >&2

  cmake --build . --parallel ${CPU_COUNT}
  cmake --build . --target tests
  cmake --install .

  cd ..

# Clean build directory
rm -rf ${BUILD_DIR}