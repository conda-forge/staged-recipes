#!/bin/bash
set -exuo pipefail

# Use newer style environment variables to initialize.
export CMAKE_GENERATOR="Ninja"
export CMAKE_INSTALL_PREFIX="${PREFIX}"
export CMAKE_PREFIX_PATH="${PREFIX}"

# Build and install C++ astcanopy library first so Python bindings can find it.
pushd ast_canopy
echo "PREFIX: ${PREFIX}"
echo "cmake; $(ls ${PREFIX}/lib/cmake/clang)"
cmake -S cpp -B cpp/build \
  ${CMAKE_ARGS:-} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_STATIC_LIBS=OFF \
  -DCMAKE_CXX_STANDARD=17
pushd cpp/build
ninja install -j${CPU_COUNT}
popd

ls -lh ${PREFIX}/lib

export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_AST_CANOPY="${PKG_VERSION}"
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
popd
