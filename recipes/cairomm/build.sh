#!/usr/bin/env bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

# This is a hack to setup the correct libc/libc++ environment
# when using clang on osx.
#
if [[ $(uname) == Darwin ]]; then
    # for Mac OSX
    export CC=clang
    export CXX=clang++
    export MACOSX_VERSION_MIN="10.7"
    export MACOSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export LDFLAGS="${LDFLAGS} -stdlib=libc++ -lc++"
    export LINKFLAGS="${LDFLAGS}"
fi

# Setup the building
./configure --prefix=${PREFIX} || { cat config.log; exit 1; }
make
make check
make install
