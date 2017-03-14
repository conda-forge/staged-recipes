#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -fPIC -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

# Configure
EXTRA_CMAKE_ARGS=""
if [ $(uname -s) == "Darwin" ]; then
  EXTRA_CMAKE_ARGS="$EXTRA_CMAKE_ARGS -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_VERSION_MIN"
  EXTRA_CMAKE_ARGS="$EXTRA_CMAKE_ARGS -DCMAKE_MACOSX_RPATH=1"
fi

mkdir -p cmake-build && cd cmake-build
cmake -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
  -DCMAKE_INSTALL_RPATH=$PREFIX/lib \
  -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
  -DBUILD_SHARED_LIBS=ON \
  -DLZFSE_BUNDLE_MODE=OFF \
  -Wno-dev \
  $EXTRA_CMAKE_ARGS $SRC_DIR

# Build
make -j$CPU_COUNT VERBOSE=1

# Test
ctest -V

# Install
make install
