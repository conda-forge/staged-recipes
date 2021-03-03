#!/usr/bin/env bash

set -ex

cd forgebuild

# call install script directly because executing the install target re-builds
# (in that case, the re-build happens because timestamps have changed)
cmake -P cmake_install.cmake

if [[ "$PKG_NAME" != limesuite ]]; then
    if [[ "$PKG_NAME" != soapysdr-module-lms7 ]]; then
        # remove Soapy SDR components
        rm -r $PREFIX/lib/SoapySDR/modules*
    fi

    if [[ $target_platform != osx* ]] ; then
        # remove GUI components
        rm -r $PREFIX/bin/LimeSuiteGUI
    fi
fi
