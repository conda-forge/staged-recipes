#!/usr/bin/env bash

if [ "$(uname)" == "Darwinaaa" ]; then
    export CONDA_BUILD_SYSROOT="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk"
#    MACOSX_VERSION_MIN=10.9
#    CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
#    CXXFLAGS="${CXXFLAGS} -stdlib=libstdc++"
#    LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
#    LINKFLAGS="${LINKFLAGS} -stdlib=libstdc++"
fi

$PYTHON -m pip install . -vv

wefiuawh