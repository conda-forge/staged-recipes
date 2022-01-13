#!/usr/bin/env bash

set -ex

cd host
cd build

# call install scripts directly because executing the install target re-builds
# (in that case, the re-build happens because timestamps have changed)

if [[ "${PKG_NAME:0:9}" == libhackrf ]]; then
    if [[ "$PKG_NAME" == libhackrf ]]; then
        # install full library
        cmake -P libhackrf/cmake_install.cmake
    else
        # install numbered library only (delete library without soversion, headers)
        cmake -P libhackrf/src/cmake_install.cmake
        rm -rf $PREFIX/include/libhackrf
        rm -f $PREFIX/lib/libhackrf${SHLIB_EXT}
    fi
    # remove static library, per CFEP-18
    rm -f $PREFIX/lib/libhackrf.a
    if [[ $target_platform == linux* ]] ; then
        # don't install udev rules with library, install them with tools package
        rm -f $PREFIX/lib/udev/rules.d/53-hackrf.rules
    fi
elif [[ "$PKG_NAME" == hackrf ]]; then
    cmake -P hackrf-tools/cmake_install.cmake

    if [[ $target_platform == linux* ]] ; then
        # install udev rule
        mkdir -p $PREFIX/lib/udev/rules.d/
        cp libhackrf/53-hackrf.rules $PREFIX/lib/udev/rules.d/
    fi
fi
