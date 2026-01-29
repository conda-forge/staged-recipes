#!/bin/bash

set -ex

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
# https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html?highlight=tegra#cross-compilation
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

if [ -z "${targetsDir+x}" ]; then
    echo "target_platform: ${target_platform} is unknown! targetsDir must be defined!" >&2
    exit 1
fi

# E.g. $CONDA_PREFIX/libexec/gcc/x86_64-conda-linux-gnu/13.3.0/cc1plus
find $CONDA_PREFIX -name cc1plus

GCC_DIR=$(dirname $(find $CONDA_PREFIX -name cc1plus))

export PATH=${GCC_DIR}:$PATH
export LD_LIBRARY_PATH=${GCC_DIR}:$LD_LIBRARY_PATH

# No need for use-linker-plugin optimization, causes compile failure, don't use it for the test
export CXXFLAGS="${CXXFLAGS} -fno-use-linker-plugin"

echo CC = $CC
echo CXX = $CXX

cmake -S $PREFIX/examples ${CMAKE_ARGS}

if [[ ${target_platform} == "linux-64" ]]; then
  cmake --build . -j"$(nproc)"
else
  cmake --build . -j"$(nproc)" \
    --target hello_world \
    --target video_replayer \
    --target activation_map \
    --target holoviz_geometry \
    --target matx_basic \
    --target tensor_interop
fi
