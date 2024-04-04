#!/bin/sh

mkdir build
cd build

if [[ ! -z "${cuda_compiler_version+x}" && "${cuda_compiler_version}" != "None" ]]
  then
    EXTRA_CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=all -DCARLSIM_NO_CUDA=OFF"
    # Remove CXX standard flags added by conda-forge. std=c++11 is required to
    # compile some .cu files
    export CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"

    # Conda-forge nvcc compiler flags environment variable doesn't match CMake environment variable
    # Redirect it so that the flags are added to nvcc calls
    export CUDAFLAGS="${CUDAFLAGS} ${CUDA_CFLAGS}"
  else
    EXTRA_CMAKE_ARGS="-DCARLSIM_NO_CUDA=ON"
fi

cp $RECIPE_DIR/cuda-samples/* $SRC_DIR/carlsim/kernel/inc/

cmake ${CMAKE_ARGS} .. \
      -DCARLSIM_SAMPLES=OFF \
      -DCARLSIM_BENCHMARKS=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      ${EXTRA_CMAKE_ARGS} \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
