#!/usr/bin/env bash

set -ex

cd forgebuild

# call install scripts directly because executing the install target re-builds
# (in that case, the re-build happens because timestamps have changed)

if [[ "$PKG_NAME" == libairspyhf ]]; then
    cmake -P libairspyhf/cmake_install.cmake
    # don't install static libraries
    rm $PREFIX/lib/libairspyhf.a
elif [[ "$PKG_NAME" == airspyhf ]]; then
    cmake -P tools/cmake_install.cmake

    if [[ $target_platform == linux* ]] ; then
        # copy udev rule so it is accessible by users
        mkdir -p $PREFIX/lib/udev/rules.d/
        cp ../tools/52-airspyhf.rules $PREFIX/lib/udev/rules.d/
    fi
fi
