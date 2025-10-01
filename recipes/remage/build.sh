#!/usr/bin/env bash

set -eux

if [[ "${DEBUG_C:-no}" == "yes" ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

if [[ "${target_platform}" == "osx-64" ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build && cd build

cmake \
    -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DRMG_CONDA_BUILD=ON \
    -DPython3_EXECUTABLE="$PYTHON" \
    -D FETCHCONTENT_TRY_FIND_PACKAGE_MODE="ALWAYS" \
    -D FETCHCONTENT_QUIET=OFF \
    -D FETCHCONTENT_FULLY_DISCONNECTED=OFF \
    -D CMAKE_REQUIRE_FIND_PACKAGE_fmt=ON \
    -D CMAKE_REQUIRE_FIND_PACKAGE_magic_enum=ON \
    -D CMAKE_REQUIRE_FIND_PACKAGE_CLI11=ON \
    ${CMAKE_ARGS} \
    "${SRC_DIR}"

make "-j${CPU_COUNT}" ${VERBOSE_CM:-}
make install "-j${CPU_COUNT}"
