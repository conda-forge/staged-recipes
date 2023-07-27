#!/usr/bin/env bash

# avoid side-injection of -std=c++14 flag in some toolchains
if [[ ${CXXFLAGS} == *"-std=c++14"* ]]; then
    echo "14 -> 17"
    export CXXFLAGS="${CXXFLAGS} -std=c++17"
fi
# Darwin modern C++
#   https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
if [[ ${target_platform} =~ osx.* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# configure
cmake \
    -S ${SRC_DIR} -B build            \
    ${CMAKE_ARGS}                     \
    -DAMReX_INSTALL=OFF               \
    -DCMAKE_BUILD_TYPE=Release        \
    -DCMAKE_VERBOSE_MAKEFILE=ON       \
    -DCMAKE_INSTALL_LIBDIR=lib        \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}  \
    -DHiPACE_COMPUTE=NOACC            \
    -DHiPACE_amrex_branch=23.07       \
    -DHiPACE_openpmd_internal=OFF     \
    -DHiPACE_MPI=OFF

# build
cmake --build build --parallel ${CPU_COUNT}

# test -> deferred to test.sh

# install
cmake --build build --target install
