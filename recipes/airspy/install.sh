#!/usr/bin/env bash

set -ex

cd forgebuild

# call install scripts directly because executing the install target re-builds
# (in that case, the re-build happens because timestamps have changed)

if [[ "$PKG_NAME" == libairspy ]]; then
    cmake -P libairspy/cmake_install.cmake
    # don't install static libraries
    rm $PREFIX/lib/libairspy.a
elif [[ "$PKG_NAME" == airspy ]]; then
    cmake -P airspy-tools/cmake_install.cmake

    if [[ $target_platform == linux* ]] ; then
        # copy udev rule so it is accessible by users
        mkdir -p $PREFIX/lib/udev/rules.d/
        cp ../airspy-tools/52-airspy.rules $PREFIX/lib/udev/rules.d/
    fi
fi
