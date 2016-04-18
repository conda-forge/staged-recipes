#!/bin/bash


ARCH_FLAG="--${ARCH}"
OSX_ARGS=""
if [[ `uname` == "Darwin" ]];
then
    export CC="clang"
    export CXX="clang++"
    OSX_ARGS="--osx-version-min=10.7 --libc++"
elif [[ `uname` == "Linux" ]];
then
    export CC="gcc"
    export CXX="g++"
fi

scons \
        ${ARCH_FLAG} \
        ${OSX_ARGS} \
        --cc="${CC}" \
        --cxx="${CXX}" \
        --ssl \
        --prefix="${PREFIX}" \
        --cpppath="${PREFIX}/include" \
        --libpath="${PREFIX}/lib" \
        --use-system-boost="${PREFIX}" \
        --use-system-pcre="${PREFIX}" \
        --use-system-snappy="${PREFIX}" \
        all

scons \
        --prefix="${PREFIX}" \
        install
