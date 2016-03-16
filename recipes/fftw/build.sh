#!/usr/bin/env bash

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    export DYLIB_EXT=dylib
    export CC=clang
    export CXX=clang++
    export CXXFLAGS="-stdlib=libc++"
    export CXX_LDFLAGS="-stdlib=libc++"
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
    export DYLIB_EXT=so
    export CC=gcc
    export CXX=g++
fi

export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"

CONFIGURE="./configure --prefix=$PREFIX --enable-shared --enable-threads --disable-fortran"

# (Note exported LDFLAGS and CFLAGS vars provided above.)
BUILD_CMD="make -j${CPU_COUNT}"
INSTALL_CMD="make install"

# Test suite
# tests are performed during building as they are not available in the
# installed package.
# Additional tests can be run with "make smallcheck" and "make bigcheck"
TEST_CMD="eval cd tests && ${LIBRARY_SEARCH_VAR}=\"$PREFIX/lib\" make check-local && cd -"

#
# We build 3 different versions of fftw:
#

# (1) Single precision (fftw libraries have "f" suffix)
$CONFIGURE --enable-float --enable-sse
${BUILD_CMD}
${INSTALL_CMD}
${TEST_CMD}

# (2) Long double precision (fftw libraries have "l" suffix)
$CONFIGURE --enable-long-double
${BUILD_CMD}
${INSTALL_CMD}
${TEST_CMD}

# (3) Double precision (fftw libraries have no precision suffix)
$CONFIGURE --enable-sse2
${BUILD_CMD}
${INSTALL_CMD}
${TEST_CMD}

unset LIBRARY_SEARCH_VAR
unset DYLIB_EXT
unset CC
unset CXX
unset CXXFLAGS
unset CXX_LDFLAGS
unset LDFLAGS
unset CFLAGS
