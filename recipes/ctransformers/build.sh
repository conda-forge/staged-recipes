#!/bin/bash
set -ex

if [[ "${target_platform}" == osx* ]]; then
    TOOLSET=clang
    CC=clang
    CXX=clang
    CXXFLAGS="${CXXFLAGS} -D_POSIX_C_SOURCE=199309L"
    $PYTHON setup.py install
elif [[ "${target_platform}" == linux* ]]; then
    TOOLSET=gcc
    CC=gcc
    CXX=g++
    cmake -B build
    cmake --build build --config Release
    $PYTHON setup.py install
fi
