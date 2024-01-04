#!/bin/bash
set -ex

cd build

if [[ "$PKG_NAME" == "libsofa-core" ]]; then
    # only the libraries (don't copy CMake metadata)
    cp -R temp_prefix/lib/libSofa*${SHLIB_EXT}* $PREFIX/lib
    if [[ $target_platform == linux* ]]; then
      # for libSofaGTestMain.a
      cp -R temp_prefix/lib/libSofa*.a $PREFIX/lib
    fi
elif [[ "$PKG_NAME" == "libsofa-core-devel" ]]; then
    #
    # if [[ "$target_platform" == "osx-arm64" ]]; then
    #     # osx-arm64 is special, because we need to generate signatures
    #     # for the libraries, which only happens on first installation;
    #     # if we overwrite the libs with the unsigned artefacts, conda
    #     # gets confused/unhappy, see #178;
    #     # therefore, copy already installed (=signed) libs into temp_prefix
    #     # before installation (=copy to $PREFIX), overwriting the unsigned
    #     # ones, ensuring that there's only one bit-for-bit variant per lib.
    #     cp $PREFIX/lib/libboost*.dylib temp_prefix/lib
    # fi

    # headers
    cp -R temp_prefix/include/. $PREFIX/include
    # CMake metadata
    cp -R temp_prefix/lib/cmake/. $PREFIX/lib/cmake
else
  echo "Invalid package to install"
  exit 1
fi