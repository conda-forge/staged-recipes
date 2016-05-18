#!/bin/bash

if [ "$(uname)" == "Darwin" ];
then
    # for Mac OSX
    unset CC
    unset CXX
    unset MACOSX_VERSION_MIN
    unset MACOSX_DEPLOYMENT_TARGET
    unset CXXFLAGS
    unset LDFLAGS
    unset LINKFLAGS
elif [ "$(uname)" == "Linux" ]
then
    # for Linux
    unset CC
    unset CXX
    unset CXXFLAGS
    unset LDFLAGS
    unset LINKFLAGS
else
    echo "This system is unsupported by our toolchain."
    exit 1
fi
