#!/bin/bash

# Hints:
# http://boost.2283326.n4.nabble.com/how-to-build-boost-with-bzip2-in-non-standard-location-td2661155.html
# http://www.gentoo.org/proj/en/base/amd64/howtos/?part=1&chap=3
# http://www.boost.org/doc/libs/1_55_0/doc/html/bbv2/reference.html

# Hints for OSX:
# http://stackoverflow.com/questions/20108407/how-do-i-compile-boost-for-os-x-64b-platforms-with-stdlibc

set -x -e
set -o pipefail

LIBRARY_PATH="${PREFIX}/lib"

# Always build PIC code for enable static linking into other shared libraries
CXXFLAGS="${CXXFLAGS} -fPIC"

if [ "$(uname)" == "Darwin" ]; then
    TOOLSET=clang
elif [ "$(uname)" == "Linux" ]; then
    TOOLSET=gcc
fi

LINKFLAGS="${LINKFLAGS} -L${LIBRARY_PATH}"

./bootstrap.sh \
    --prefix="${PREFIX}" \
    --with-icu="${PREFIX}" \
    --with-python="${PYTHON}" \
    --with-python-root="${PREFIX} : ${PREFIX}/include/python${PY_VER}m ${PREFIX}/include/python${PY_VER}" \
    2>&1 | tee bootstrap.log

./b2 -q \
    variant=release \
    address-model="${ARCH}" \
    architecture=x86 \
    debug-symbols=off \
    threading=multi \
    runtime-link=shared \
    link=static,shared \
    toolset=${TOOLSET} \
    python="${PY_VER}" \
    cxxflags="${CXXFLAGS}" \
    linkflags="${LINKFLAGS}" \
    --layout=system \
    --with-python \
    -j"${CPU_COUNT}" \
    install 2>&1 | tee b2.log
