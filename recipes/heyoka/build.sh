#!/usr/bin/env bash

if [[ "$(uname)" == "Darwin" ]]; then
    export ENABLE_MPPP=no
    export AR_CMAKE_SETTING=
    export RANLIB_CMAKE_SETTING=
    # Workaround for missing C++17 feature when building the tests.
    # Also, workaround for compile issue on older OSX SDKs.
    export CXXFLAGS="$CXXFLAGS -DCATCH_CONFIG_NO_CPP17_UNCAUGHT_EXCEPTIONS -D_LIBCPP_DISABLE_AVAILABILITY"
else
    export ENABLE_MPPP=yes
    # Workaround for making the LTO machinery work on Linux.
    export AR_CMAKE_SETTING="-DCMAKE_CXX_COMPILER_AR=$GCC_AR -DCMAKE_C_COMPILER_AR=$GCC_AR"
    export RANLIB_CMAKE_SETTING="-DCMAKE_CXX_COMPILER_RANLIB=$GCC_RANLIB -DCMAKE_C_COMPILER_RANLIB=$GCC_RANLIB"
fi

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DHEYOKA_WITH_MPPP=$ENABLE_MPPP \
    -DHEYOKA_BUILD_TESTS=yes \
    -DHEYOKA_WITH_SLEEF=yes \
    -DHEYOKA_ENABLE_IPO=yes \
    -DBoost_NO_BOOST_CMAKE=ON \
    $AR_CMAKE_SETTING \
    $RANLIB_CMAKE_SETTING \
    -DHEYOKA_INSTALL_LIBDIR=lib \
    ..

make -j${CPU_COUNT} VERBOSE=1

ctest -j${CPU_COUNT} --output-on-failure

make install
