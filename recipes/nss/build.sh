#!/bin/bash


if [[ `uname` == "Darwin" ]]
then
    export CC=clang
    export CXX=clang++
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export MACOSX_DEPLOYMENT_TARGET=10.7
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export CC=gcc
    export CXX=g++
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export ARCH_FLAG=""
if [[ "${ARCH}" == 64 ]]
then
    export USE_64=true
fi

cd nss
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make \
      PREFIX="${PREFIX}" \
      NSPR_PREFIX="${PREFIX}" \
      NSPR_INCLUDE_DIR="${PREFIX}/include/nspr" \
      CC=$CC \
      CXX=$CXX \
      C_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/nspr" \
      LIBRARY_PATH="${PREFIX}/lib" \
      USE_SYSTEM_ZLIB=1 \
      NSS_USE_SYSTEM_SQLITE=1 \

# test
cd tests
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib HOST=localhost DOMSUF=localdomain ./all.sh
