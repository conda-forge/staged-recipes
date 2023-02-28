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

# IPO/LTO does only work with certain toolchains
HiPACE_IPO=ON
if [[ ${target_platform} =~ osx.* ]]; then
    HiPACE_IPO=OFF
fi

# configure
cmake \
    -S ${SRC_DIR} -B build                \
    ${CMAKE_ARGS}                         \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo     \
    -DCMAKE_VERBOSE_MAKEFILE=ON           \
    -DCMAKE_INSTALL_LIBDIR=lib            \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}      \
    -DHiPACE_COMPUTE=NOACC               \
    -DHiPACE_IPO=${HiPACE_IPO}           \
    -DHiPACE_amrex_branch=23.02          \
    -DHiPACE_MPI=OFF

# build
cmake --build build --parallel ${CPU_COUNT}

# test
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
    ctest --test-dir build --output-on-failure
fi

# install
cmake --build build --target install
