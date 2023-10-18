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
    -DBUILD_SHARED_LIBS=ON            \
    -DCMAKE_BUILD_TYPE=Release        \
    -DCMAKE_VERBOSE_MAKEFILE=ON       \
    -DCMAKE_INSTALL_LIBDIR=lib        \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}  \
    -DpyAMReX_amrex_internal=OFF      \
    -DpyAMReX_pybind11_internal=OFF   \
    -DPython_EXECUTABLE=${PYTHON}     \
    -DPython_INCLUDE_DIR=$(${PYTHON} -c "from sysconfig import get_paths as gp; print(gp()['include'])") \
    -DPYINSTALLOPTIONS="--no-build-isolation"

# build, pack & install
cmake --build build --parallel ${CPU_COUNT} --target pip_install_nodeps
