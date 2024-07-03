#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_SHARED_LIBS=ON \
  -DMOMENTUM_USE_SYSTEM_RERUN_CPP_SDK=ON \
  -DMOMENTUM_BUILD_TESTING=OFF \
  -DMOMENTUM_BUILD_EXAMPLES=OFF \
  -DMOMENTUM_BUILD_PYMOMENTUM=OFF \
  -DMOMENTUM_BUILD_WITH_EZC3D=OFF \
  -DMOMENTUM_BUILD_WITH_OPENFBX=OFF

cmake --build build --parallel

cmake --build build --parallel --target install
