#!/usr/bin/env bash

mkdir build
cd build

export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
source $PREFIX/share/triqs/triqsvars.sh

cmake ${CMAKE_ARGS} \
    -DCMAKE_CXX_COMPILER=${BUILD_PREFIX}/bin/$(basename ${CXX}) \
    -DCMAKE_C_COMPILER=${BUILD_PREFIX}/bin/$(basename ${CC}) \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBuild_Deps=IfNotFound \
    ..

make -j1 VERBOSE=1
CTEST_OUTPUT_ON_FAILURE=1 ctest
make install

# Rewrite any build-prefix path leaked into the installed CMake targets file.
tgt="${PREFIX}/lib/cmake/${PKG_NAME}/${PKG_NAME}-targets.cmake"
if [[ -f "$tgt" ]]; then
  sed "s|$BUILD_PREFIX|$PREFIX|g" "$tgt" > tmp_file
  cp tmp_file "$tgt"
fi
