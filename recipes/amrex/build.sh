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
    -DAMReX_ASCENT=OFF                \
    -DAMReX_BUILD_TUTORIALS=OFF       \
    -DAMReX_CONDUIT=OFF               \
    -DAMReX_CUDA_LTO=OFF              \
    -DAMReX_EB=OFF                    \
    -DAMReX_ENABLE_TESTS=ON           \
    -DAMReX_FORTRAN=OFF               \
    -DAMReX_FORTRAN_INTERFACES=OFF    \
    -DAMReX_GPU_BACKEND=NONE          \
    -DAMReX_GPU_RDC=OFF               \
    -DAMReX_HDF5=OFF                  \
    -DAMReX_HYPRE=OFF                 \
    -DAMReX_IPO=OFF                   \
    -DAMReX_MPI=OFF                   \
    -DAMReX_MPI_THREAD_MULTIPLE=OFF   \
    -DAMReX_OMP=ON                    \
    -DAMReX_PARTICLES=ON              \
    -DAMReX_PLOTFILE_TOOLS=OFF        \
    -DAMReX_PROBINIT=OFF              \
    -DAMReX_PIC=ON                    \
    -DAMReX_SPACEDIM="1;2;3"          \
    -DAMReX_SENSEI=OFF                \
    -DAMReX_TEST_TYPE=Small           \
    -DAMReX_TINY_PROFILE=ON           \
    -DBUILD_SHARED_LIBS=ON            \
    -DCMAKE_BUILD_TYPE=Release        \
    -DCMAKE_VERBOSE_MAKEFILE=ON       \
    -DCMAKE_INSTALL_LIBDIR=lib        \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

# build
cmake --build build --parallel ${CPU_COUNT}

# test
OMP_NUM_THREADS=2 ctest --test-dir build --output-on-failure

# install
cmake --build build --target install

