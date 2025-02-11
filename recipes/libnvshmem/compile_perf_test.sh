
#!/bin/bash

set -ex

#GPU Arch - anything recent should do but change accordingly if build breaks
SM=89

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

# E.g. $CONDA_PREFIX/libexec/gcc/x86_64-conda-linux-gnu/13.3.0/cc1plus
find $CONDA_PREFIX -name cc1plus

GCC_DIR=$(dirname $(find $CONDA_PREFIX -name cc1plus))

export PATH=${GCC_DIR}:$PATH
export LD_LIBRARY_PATH=${GCC_DIR}:$LD_LIBRARY_PATH

# No need for use-linker-plugin optimization, causes compile failure, don't use it for the test
export CXXFLAGS="${CXXFLAGS} -fno-use-linker-plugin"

echo CC =  $CC
echo CXX =  $CXX

cmake -S $PREFIX/share/src/perftest \
  -DCMAKE_LIBRARY_PATH=${GCC_DIR} \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_CUDA_COMPILER=$PREFIX/bin/nvcc \
  -DCMAKE_CXX_COMPILER=$CXX \
  -DCUDAToolkit_INCLUDE_DIRECTORIES="$PREFIX/include;$PREFIX/${targetsDir}/include" \
  -DNVSHMEM_MPI_SUPPORT=0 \
  -DNVSHMEM_PREFIX=$PREFIX \
  -DCUDA_HOME=$PREFIX \
  -DCMAKE_CUDA_ARCHITECTURES="${SM}"

cmake --build .
