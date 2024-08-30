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
    -DHeffte_DISABLE_GPU_AWARE_MPI=ON \
    -DHeffte_ENABLE_AVX=ON            \
    -DHeffte_ENABLE_AVX512=OFF        \
    -DHeffte_ENABLE_FFTW=ON           \
    -DHeffte_ENABLE_CUDA=OFF          \
    -DHeffte_ENABLE_ROCM=OFF          \
    -DHeffte_ENABLE_ONEAPI=OFF        \
    -DHeffte_ENABLE_MKL=OFF           \
    -DHeffte_ENABLE_DOXYGEN=OFF       \
    -DHeffte_SEQUENTIAL_TESTING=ON    \
    -DHeffte_ENABLE_TESTING=ON        \
    -DHeffte_ENABLE_TRACING=OFF       \
    -DHeffte_ENABLE_PYTHON=OFF        \
    -DHeffte_ENABLE_FORTRAN=OFF       \
    -DHeffte_ENABLE_SWIG=OFF          \
    -DHeffte_ENABLE_MAGMA=OFF

# build, pack & install
cmake --build build --parallel ${CPU_COUNT} --target install
