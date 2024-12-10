#!/bin/bash

set -ex

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

cp -vf $PREFIX/examples/hello_world/cpp/CMakeLists.txt .
cp -vf $PREFIX/examples/hello_world/cpp/hello_world.cpp .

# E.g. $CONDA_PREFIX/libexec/gcc/x86_64-conda-linux-gnu/13.3.0/cc1plus
find $CONDA_PREFIX -name cc1plus

GCC_DIR=$(dirname $(find $CONDA_PREFIX -name cc1plus))

export PATH=${GCC_DIR}:$PATH
export LD_LIBRARY_PATH=${GCC_DIR}:$LD_LIBRARY_PATH

# No need for use-linker-plugin optimization, causes compile failure, don't use it for the test
export CXXFLAGS="${CXXFLAGS} -fno-use-linker-plugin"

echo CC =  $CC
echo CXX =  $CXX

cmake . \
  -DCMAKE_LIBRARY_PATH=${GCC_DIR} \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_CXX_COMPILER=$CXX \
  -DCUDAToolkit_INCLUDE_DIRECTORIES="$PREFIX/include;$PREFIX/${targetsDir}/include"

cmake --build .

test -f hello_world && test -x hello_world

./hello_world
