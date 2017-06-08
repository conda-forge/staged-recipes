#!/bin/bash

if [ "$(uname)" == "Darwin" ]
then
    # for Mac OSX
    export CC=clang
    export CXX=clang++
    export CONDA_FORGE_MACOSX_VERSION_MIN="10.9"
    export MACOSX_DEPLOYMENT_TARGET="${CONDA_FORGE_MACOSX_VERSION_MIN}"
    export CMAKE_OSX_DEPLOYMENT_TARGET="${CONDA_FORGE_MACOSX_VERSION_MIN}"
    export CONDA_FORGE_CFLAGS="${CONDA_FORGE_CFLAGS} -mmacosx-version-min=${CONDA_FORGE_MACOSX_VERSION_MIN}"
    export CONDA_FORGE_CXXFLAGS="${CONDA_FORGE_CXXFLAGS} -mmacosx-version-min=${CONDA_FORGE_MACOSX_VERSION_MIN}"
    export CONDA_FORGE_CXXFLAGS="${CONDA_FORGE_CXXFLAGS} -stdlib=libc++"
    export CONDA_FORGE_LDFLAGS="${CONDA_FORGE_LDFLAGS} -headerpad_max_install_names"
    export CONDA_FORGE_LDFLAGS="${CONDA_FORGE_LDFLAGS} -mmacosx-version-min=${CONDA_FORGE_MACOSX_VERSION_MIN}"
    export CONDA_FORGE_LDFLAGS="${CONDA_FORGE_LDFLAGS} -lc++"
elif [ "$(uname)" == "Linux" ]
then
    # for Linux
    export CC=gcc
    export CXX=g++
    # Boost wants to enable `float128` support on Linux by default.
    # However, we don't install `libquadmath` so it will fail to find
    # the needed headers and fail to compile things. Adding this flag
    # tells Boost not to support `float128` and avoids this search
    # process. As it has confused a few people. We have added it here.
    # The idea to add this flag was inspired by this Boost ticked.
    #
    # https://svn.boost.org/trac/boost/ticket/9240
    #
    export CONDA_FORGE_CXXFLAGS="${CONDA_FORGE_CXXFLAGS} -DBOOST_MATH_DISABLE_FLOAT128"
else
    echo "This system is unsupported by the toolchain."
    exit 1
fi

export CONDA_FORGE_CFLAGS="${CONDA_FORGE_CFLAGS} -m${ARCH}"
export CONDA_FORGE_CXXFLAGS="${CONDA_FORGE_CXXFLAGS} -m${ARCH}"
export CONDA_FORGE_CPPFLAGS="${CONDA_FORGE_CPPFLAGS} -I${PREFIX}/include"
export CONDA_FORGE_LDFLAGS="${CONDA_FORGE_LDFLAGS} -L${PREFIX}/lib"

export _OLD_PATH=${PATH}
export PATH="${PREFIX}/bin/cf:${PATH}"
