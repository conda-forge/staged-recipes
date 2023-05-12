#!/bin/bash
set -e
set -x
cmake_version=$(cmake --version | grep version | awk '{print $3}')

mkdir -p cmake-tests
git clone -b v${cmake_version} --depth 1 https://gitlab.kitware.com/cmake/cmake.git cmake-tests
cmake -S cmake-tests -B cmake-tests/build -DCMake_TEST_HOST_CMAKE=ON -DCMake_TEST_CUDA=nvcc -G "Ninja"
cd cmake-tests/build

# Test exclusion list:
# Requires cublas
#   Cuda.ProperDeviceLibraries
#
# Requires curand
#   *SharedRuntime*
#
# Requires execution on a machine with a CUDA GPU
#   Cuda.ObjectLibrary
#   Cuda.WithC
#   CudaOnly.ArchSpecial
#   CudaOnly.GPUDebugFlag
#   CudaOnly.SeparateCompilationPTX
#   CudaOnly.WithDefs
#   RunCMake.CUDA_architectures
#   *Toolkit*
# Failing due to undefined symbol: __libc_dl_error_tsd, version GLIBC_PRIVATE
#   Cuda.Complex
CUDAHOSTCXX=$CXX ctest -L CUDA --output-on-failure -j $(nproc) -E "(ProperDeviceLibraries|SharedRuntime|ObjectLibrary|WithC|ArchSpecial|GPUDebugFlag|SeparateCompilationPTX|WithDefs|CUDA_architectures|Toolkit|Cuda.Complex)"
