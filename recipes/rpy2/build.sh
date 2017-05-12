#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # for Mac OSX
    export CC=clang
    export CXX=clang++
    export MACOSX_VERSION_MIN="10.9"
    export MACOSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
    export CMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
    export CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export LDFLAGS="${LDFLAGS} -lc++"
    export LINKFLAGS="${LDFLAGS}"
fi

if [[ $(uname) == "Linux" && ${ARCH} == 32 && ${PY_VER} == 3.6 ]]; then
  # See https://bitbucket.org/rpy2/rpy2/issues/389/failed-to-compile-with-python-360-on-32
  CFLAGS="-I${PREFIX}/include ${CFLAGS} -DHAVE_UINTPTR_T=1" "${PYTHON}" setup.py install --single-version-externally-managed --record=record.txt
else
  CFLAGS="-I${PREFIX}/include ${CFLAGS}" "${PYTHON}" setup.py install --single-version-externally-managed --record=record.txt
fi
