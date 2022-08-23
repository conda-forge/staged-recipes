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
ImpactX_IPO=ON
if [[ ${target_platform} =~ osx.* ]]; then
    ImpactX_IPO=OFF
fi

# configure
cmake \
    -S ${SRC_DIR} -B build                \
    ${CMAKE_ARGS}                         \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo     \
    -DCMAKE_VERBOSE_MAKEFILE=ON           \
    -DCMAKE_INSTALL_LIBDIR=lib            \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}      \
    -DImpactX_COMPUTE=NOACC               \
    -DImpactX_IPO=${ImpactX_IPO}          \
    -DImpactX_amrex_branch=22.08          \
    -DImpactX_pyamrex_branch=c11acfaf08162fe42c5ee07c086d23f2874fa779 \
    -DImpactX_LIB=ON      \
    -DImpactX_MPI=OFF     \
    -DImpactX_PYTHON=ON   \
    -DPython3_FIND_STRATEGY=LOCATION

# build
cmake --build build --parallel ${CPU_COUNT}
cmake --build build --parallel ${CPU_COUNT} --target pyamrex_pip_wheel
cmake --build build --parallel ${CPU_COUNT} --target pip_wheel

# test
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
    ctest --test-dir build --output-on-failure -E AMReX
fi

# install
cmake --build build --target install
${PYTHON} -m pip install --force-reinstall --no-index --no-deps -vv --find-links=build/_deps/fetchedpyamrex-build amrex
${PYTHON} -m pip install --force-reinstall --no-index --no-deps -vv --find-links=build impactx
