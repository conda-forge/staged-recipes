#!/bin/sh

set -ex

mkdir -p build
cd build

# function for facilitate version comparison; cf. https://stackoverflow.com/a/37939589
function version2int { echo "$@" | awk -F. '{ printf("%d%02d\n", $1, $2); }'; }

# for documentation see e.g.
# docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
# docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#ptxas-options-gpu-name
# docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list

# the following are all the x86-relevant gpu arches
ARCHES=(52 60 61 70)
if [ $(version2int $cuda_compiler_version) -ge $(version2int "11.1") ]; then
    # Ampere support for GeForce 30 (sm_86) needs cuda >= 11.1
    LATEST_ARCH=86
    # ARCHES does not contain LATEST_ARCH; see usage below
    ARCHES=( "${ARCHES[@]}" 75 80 )
elif [ $(version2int $cuda_compiler_version) -ge $(version2int "11.0") ]; then
    # Ampere support for A100 (sm_80) needs cuda >= 11.0
    LATEST_ARCH=80
    ARCHES=( "${ARCHES[@]}" 75 )
fi
for arch in "${ARCHES[@]}"; do
    CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${arch}-real"
done
# for -real vs. -virtual, see cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
# this is to support PTX JIT compilation; see first link above or cf.
# devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching
CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${LATEST_ARCH}"

cmake \
    ${CMAKE_ARGS} \
    -DPROJECT_BINARY_DIR=$PREFIX \
    -DFAISS_PATH=$PREFIX/lib/libfaiss.so \
    -DCMAKE_CUDA_ARCHITECTURES="${CMAKE_CUDA_ARCHS}" \
    ..

make
make install
cd ..

cd python
$PYTHON setup.py install
