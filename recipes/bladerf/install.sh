#!/usr/bin/env bash

set -ex

cd build

# call install scripts directly because executing the install target re-builds
# (in that case, the re-build happens because timestamps have changed)

if [[ "${PKG_NAME:0:10}" == libbladerf ]]; then
    # install full library
    cmake -P host/libraries/libbladeRF/cmake_install.cmake
    if [[ "$PKG_NAME" != libbladerf ]]; then
        # install numbered library only (delete library without soversion, headers)
        rm -f $PREFIX/include/bladeRF*.h
        rm -f $PREFIX/include/libbladeRF.h
        rm -f $PREFIX/lib/pkgconfig/libbladeRF.pc
        rm -f $PREFIX/lib/libbladeRF${SHLIB_EXT}
    fi
elif [[ "$PKG_NAME" == bladerf ]]; then
    cmake -P cmake_install.cmake
fi
