#! /bin/bash

set -e
set -x

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=ON \
    -DSURELOG_BUILD_TESTS=OFF \
    -DSURELOG_USE_HOST_ALL=ON \
    -DSURELOG_USE_HOST_ANTLR=ON \
    -DSURELOG_USE_HOST_CAPNP=ON \
    -DSURELOG_USE_HOST_GTEST=ON \
    -DSURELOG_USE_HOST_JSON=ON \
    -DSURELOG_USE_HOST_UHDM=ON \
    -DSURELOG_WITH_TCMALLOC=OFF \
    -DSURELOG_WITH_ZLIB=ON \
    -DCMAKE_MACOSX_RPATH=1 \
    -DCMAKE_INSTALL_RPATH=$PREFIX/lib \
    -DPYTHON_EXECUTABLE="$PYTHON" \
    -DPython3_EXECUTABLE="$PYTHON" \
    -DANTLR_JAR_LOCATION="$PREFIX/lib/antlr4-4.13.1-complete.jar" \
    -DCMAKE_FIND_FRAMEWORK=NEVER \
    -DCMAKE_FIND_APPBUNDLE=NEVER

cmake --build build --config Release
cmake --install build --config Release
