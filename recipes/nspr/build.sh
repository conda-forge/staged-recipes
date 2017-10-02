#!/bin/bash


if [[ `uname` == "Darwin" ]]
then
    export CC=clang
    export CXX=clang++
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export MACOSX_DEPLOYMENT_TARGET=10.7
    export MAC_FLAGS="--enable-macos-target=${MACOSX_DEPLOYMENT_TARGET}"
fi

export ARCH_FLAG=""
if [[ "${ARCH}" == 64 ]]
then
    export ARCH_FLAG="--enable-64bit"
fi


cd nspr
./configure \
             --prefix="${PREFIX}" \
             $ARCH_FLAG \
             $MAC_FLAGS
make
make install
