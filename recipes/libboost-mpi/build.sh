#!/bin/bash

# Hints:
# http://boost.2283326.n4.nabble.com/how-to-build-boost-with-bzip2-in-non-standard-location-td2661155.html
# http://www.gentoo.org/proj/en/base/amd64/howtos/?part=1&chap=3
# http://www.boost.org/doc/libs/1_55_0/doc/html/bbv2/reference.html

# Hints for OSX:
# http://stackoverflow.com/questions/20108407/how-do-i-compile-boost-for-os-x-64b-platforms-with-stdlibc

set -x -e

INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"

# Always build PIC code for enable static linking into other shared libraries
CXXFLAGS="${CXXFLAGS} -fPIC"

if [[ "${target_platform}" == osx* ]]; then
    TOOLSET=clang
elif [[ "${target_platform}" == linux* ]]; then
    TOOLSET=gcc
fi

# http://www.boost.org/build/doc/html/bbv2/tasks/crosscompile.html
cat <<EOF > ${SRC_DIR}/tools/build/src/site-config.jam
using ${TOOLSET} : : ${CXX} ;
using mpi ;
EOF

LINKFLAGS="${LINKFLAGS} -L${LIBRARY_PATH}"

CXX=${CXX_FOR_BUILD:-${CXX}} CC=${CC_FOR_BUILD:-${CC}} ./bootstrap.sh \
    --prefix="${PREFIX}" \
    --with-libraries=mpi \
    --with-toolset=${TOOLSET} \
    --with-icu="${PREFIX}" || (cat bootstrap.log; exit 1)

ADDRESS_MODEL="${ARCH}"
ARCHITECTURE=x86
ABI="sysv"

if [ "${ADDRESS_MODEL}" == "aarch64" ] || [ "${ADDRESS_MODEL}" == "arm64" ]; then
    ADDRESS_MODEL=64
    ARCHITECTURE=arm
    ABI="aapcs"
elif [ "${ADDRESS_MODEL}" == "ppc64le" ]; then
    ADDRESS_MODEL=64
    ARCHITECTURE=power
fi

if [[ "$target_platform" == osx-* ]]; then
    BINARY_FORMAT="mach-o"
elif [[ "$target_platform" == linux-* ]]; then
    BINARY_FORMAT="elf"
fi

./b2 -q \
    variant=release \
    address-model="${ADDRESS_MODEL}" \
    architecture="${ARCHITECTURE}" \
    binary-format="${BINARY_FORMAT}" \
    abi="${ABI}" \
    debug-symbols=off \
    threading=multi \
    runtime-link=shared \
    link=shared \
    install-dependencies=off \
    toolset=${TOOLSET} \
    include="${INCLUDE_PATH}" \
    cxxflags="${CXXFLAGS}" \
    linkflags="${LINKFLAGS}" \
    --layout=system \
    -j"${CPU_COUNT}" \
    install

# Remove all headers as we only build Boost.MPI libraries.
rm -r "${PREFIX}/include/boost"

# Remove all CMake config as we only build Boost.MPI libraries.
rm -r "${PREFIX}/lib/cmake"
