#!/bin/bash

set -e

mkdir -p _build
cd _build

# set C++ standard to c++14
#   - igwn-cmake sets c++11, which is too old for root
if [ "$(uname)" = "Darwin" ]; then
  # ldas-tools-al doesn't work with c++17 on macOS
  export CXXFLAGS="${CXXFLAGS} -std=c++14"
else
  export CXXFLAGS="${CXXFLAGS} -std=c++17"
fi

${SRC_DIR}/configure \
  --disable-static \
  --enable-dtt \
  --enable-online \
  --enable-shared \
  --includedir="${PREFIX}/include/gds" \
  --prefix="${PREFIX}" \
;

# build
make -j ${CPU_COUNT} VERBOSE=1 V=1

# test
make -j ${CPU_COUNT} VERBOSE=1 V=1 check

# install
make -j ${CPU_COUNT} VERBOSE=1 V=1 install
