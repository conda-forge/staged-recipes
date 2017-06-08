#!/bin/bash

if [ "$(uname)" == "Darwin" ];
then
    # for Mac OSX
    unset CC
    unset CXX
    unset MACOSX_VERSION_MIN
    unset MACOSX_DEPLOYMENT_TARGET
    unset CMAKE_OSX_DEPLOYMENT_TARGET
    unset CONDA_FORGE_CFLAGS
    unset CONDA_FORGE_CPPFLAGS
    unset CONDA_FORGE_CXXFLAGS
    unset CONDA_FORGE_LDFLAGS
elif [ "$(uname)" == "Linux" ]
then
    # for Linux
    unset CC
    unset CXX
    unset CONDA_FORGE_CFLAGS
    unset CONDA_FORGE_CPPFLAGS
    unset CONDA_FORGE_CXXFLAGS
    unset CONDA_FORGE_LDFLAGS
else
    echo "This system is unsupported by our toolchain."
    exit 1
fi

export PATH="${_OLD_PATH}"
