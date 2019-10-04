#!/usr/bin/env bash

set -o errexit

scripts/build-dependency abseil dlpack fmt gtest pybind11

mkdir -p build && cd build

cmake -GNinja\
      ${CONDA_BUILD_SYSROOT:+-DCMAKE_OSX_SYSROOT="$CONDA_BUILD_SYSROOT"}\
      -DCMAKE_BUILD_TYPE=RelWithDebInfo\
      -DCMAKE_INSTALL_PREFIX="$PREFIX"\
      -DIconv_IS_BUILT_IN=FALSE\
      -DMLIO_INCLUDE_TESTS=TRUE\
      -DMLIO_INCLUDE_DOC=TRUE\
      -DMLIO_ENABLE_LTO=TRUE ..

cmake --build .
cmake --build . --target mlio-doc
cmake --build . --target test

cmake -DCOMPONENT=runtime -P cmake_install.cmake
