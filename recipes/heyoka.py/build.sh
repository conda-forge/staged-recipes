#!/usr/bin/env bash

mkdir build
cd build

if [[ "$(uname)" == "Darwin" ]]; then
    export AR_CMAKE_SETTING=
    export RANLIB_CMAKE_SETTING=
else
    # Workaround for making the LTO machinery work on Linux.
    export AR_CMAKE_SETTING="-DCMAKE_CXX_COMPILER_AR=$GCC_AR -DCMAKE_C_COMPILER_AR=$GCC_AR"
    export RANLIB_CMAKE_SETTING="-DCMAKE_CXX_COMPILER_RANLIB=$GCC_RANLIB -DCMAKE_C_COMPILER_RANLIB=$GCC_RANLIB"
fi

cmake \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DHEYOKA_PY_ENABLE_IPO=yes \
    $AR_CMAKE_SETTING \
    $RANLIB_CMAKE_SETTING \
    ..

make -j${CPU_COUNT} VERBOSE=1

make install
