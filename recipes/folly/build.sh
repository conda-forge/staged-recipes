#!/usr/bin/env bash

set -ex

# Folly uses C++14
export CXXFLAGS="`echo $CXXFLAGS | sed 's/-std=c++17/-std=c++14/'`"

export EXTRA_CMAKE_OPTIONS="-GNinja"

# Resolves error: 'scm_timestamping' does not name a type
export CXXFLAGS="$CXXFLAGS -DFOLLY_HAVE_SO_TIMESTAMPING=0"

# Resolves error: expected ')' before 'PRId64'
export CXXFLAGS="$CXXFLAGS -D__STDC_FORMAT_MACROS"

# https://github.com/facebook/folly/issues/976
#export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DFOLLY_USE_JEMALLOC=OFF"

# Build shared library
export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DBUILD_SHARED_LIBS=ON"

# Resolves #error No clock_gettime(3) compatibility wrapper available for this platform.
export CXXFLAGS="$CXXFLAGS -DFOLLY_HAVE_CLOCK_GETTIME=1"

mkdir -p _build
cd _build

cmake -Wno-dev \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  $EXTRA_CMAKE_OPTIONS \
  ..

cmake --build . --parallel

cmake --install .

cd ..

