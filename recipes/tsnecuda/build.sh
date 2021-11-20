#!/bin/bash

set -ex

# function for facilitate version comparison; cf. https://stackoverflow.com/a/37939589
function version2int { echo "$@" | awk -F. '{ printf("%d%02d\n", $1, $2); }'; }

# adapted from https://github.com/conda-forge/faiss-split-feedstock/blob/master/recipe/build-lib.sh
declare -a CUDA_CONFIG_ARGS

# the following are all the x86-relevant gpu arches; for building aarch64-packages, add: 53, 62, 72
ARCHES=(52 60 61 70)
# cuda 11.0 deprecates arches 35, 50
DEPRECATED_IN_11=(35 50)
if [ $(version2int $cuda_compiler_version) -ge $(version2int "11.1") ]; then
    # Ampere support for GeForce 30 (sm_86) needs cuda >= 11.1
    LATEST_ARCH=86
    # ARCHES does not contain LATEST_ARCH; see usage below
    ARCHES=( "${ARCHES[@]}" 75 80 )
elif [ $(version2int $cuda_compiler_version) -ge $(version2int "11.0") ]; then
    # Ampere support for A100 (sm_80) needs cuda >= 11.0
    LATEST_ARCH=80
    ARCHES=( "${ARCHES[@]}" 75 )
elif [ $(version2int $cuda_compiler_version) -ge $(version2int "10.0") ]; then
    # Turing support (sm_75) needs cuda >= 10.0
    LATEST_ARCH=75
    ARCHES=( "${DEPRECATED_IN_11[@]}" "${ARCHES[@]}" )
fi
for arch in "${ARCHES[@]}"; do
    CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${arch}-real"
done
# for -real vs. -virtual, see cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html
# this is to support PTX JIT compilation; see first link above or cf.
# devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching
CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${LATEST_ARCH}"

CUDA_CONFIG_ARGS+=(
    -DCMAKE_CUDA_ARCHITECTURES="${CMAKE_CUDA_ARCHS}"
)
# cmake does not generate output for the call below; echo some info
echo "Set up extra cmake-args: CUDA_CONFIG_ARGS=${CUDA_CONFIG_ARGS+"${CUDA_CONFIG_ARGS[@]}"}"

cmake \
    -DCMAKE_CUDA_COMPILER=$CUDA_HOME/bin/nvcc
    -DBUILD_TEST=TRUE \
    -DWITH_ZMQ=TRUE \
    ${CUDA_CONFIG_ARGS+"${CUDA_CONFIG_ARGS[@]}"} \
    .

# compile
make -j$CPU_COUNT

cd build/python

# why -e ...?
pip install -e .
