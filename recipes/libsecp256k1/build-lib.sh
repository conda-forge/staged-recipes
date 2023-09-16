#!/usr/bin/env bash
set -ex

# Prepare post-install tests
if [[ "${PKG_NAME: -8}" != "-headers" ]]; then
  cp ${SRC_DIR}/src/tests.c ${RECIPE_DIR}/standalone_tests/src
  cp ${SRC_DIR}/src/tests_exhaustive.c ${RECIPE_DIR}/standalone_tests/src
  cp ${SRC_DIR}/src/secp256k1.c ${RECIPE_DIR}/standalone_tests/src
  (cd ${SRC_DIR}; tar cf - contrib | (cd ${RECIPE_DIR}/standalone_tests; tar xf -))
  (cd ${SRC_DIR}; tar cf - cmake | (cd ${RECIPE_DIR}/standalone_tests/src; tar xf -))
  (cd ${SRC_DIR}/src; tar cf - *.h modules/*/*.h wycheproof/*.h | (cd ${RECIPE_DIR}/standalone_tests/src; tar xf -))
fi

# Build
if [[ "${PKG_NAME: -8}" == "-headers" ]]; then
  BUILD_DIR="build-headers"
  export SECP256K1_BUILD_SHARED_LIBS="OFF"
  export SECP256K1_INSTALL_HEADERS="ON"
  export SECP256K1_INSTALL="OFF"
elif [[ "${PKG_NAME: -7}" == "-static" ]]; then
  BUILD_DIR="build-static"
  export SECP256K1_BUILD_SHARED_LIBS="OFF"
  export SECP256K1_INSTALL_HEADERS="OFF"
  export SECP256K1_INSTALL="ON"
else
  BUILD_DIR="build"
  export SECP256K1_BUILD_SHARED_LIBS="ON"
  export SECP256K1_INSTALL_HEADERS="OFF"
  export SECP256K1_INSTALL="ON"
fi

mkdir -p ${BUILD_DIR}
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

if [[ "${PKG_NAME: -8}" == "-headers" ]]; then
  echo "Installing headers only" >&2
  echo "   PKG_NAME=${PKG_NAME}" >&2
  echo "   SECP256K1_BUILD_SHARED_LIBS=${SECP256K1_BUILD_SHARED_LIBS}" >&2
  echo "   SECP256K1_INSTALL_HEADERS=${SECP256K1_INSTALL_HEADERS}" >&2
  echo "   SECP256K1_INSTALL=${SECP256K1_INSTALL}" >&2
  cmake --install .
else
  echo "Installing Library" >&2
  echo "   PKG_NAME=${PKG_NAME}" >&2
  echo "   SECP256K1_BUILD_SHARED_LIBS=${SECP256K1_BUILD_SHARED_LIBS}" >&2
  echo "   SECP256K1_INSTALL_HEADERS=${SECP256K1_INSTALL_HEADERS}" >&2
  echo "   SECP256K1_INSTALL=${SECP256K1_INSTALL}" >&2
  cmake --build . --parallel ${CPU_COUNT}
  cmake --build . --target tests
  cmake --install .
fi
cd ..