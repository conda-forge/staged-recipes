#!/bin/bash
set -ex

cd build

if [[ "$PKG_NAME" == "libsofa-core" ]]; then
    # only the libraries (don't copy CMake metadata)
    cp -R temp_prefix/lib/libSofa*${SHLIB_EXT}* $PREFIX/lib
elif [[ "$PKG_NAME" == "libsofa-core-devel" ]]; then
    # headers
    cp -R temp_prefix/include/. $PREFIX/include
    # CMake metadata
    cp -R temp_prefix/lib/cmake/Sofa* $PREFIX/lib/cmake
else
  echo "Invalid package to install"
  exit 1
fi