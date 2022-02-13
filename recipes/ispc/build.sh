#!/bin/bash

# Use our compilers instead of clang/clang++
sed -i.bak 's|set(CMAKE_C_COMPILER|set(CMAKE_C_COMPILER_BAK|g' CMakeLists.txt
sed -i.bak 's|set(CMAKE_CXX_COMPILER|set(CMAKE_CXX_COMPILER_BAK|g' CMakeLists.txt

mkdir build
cd build
cmake $CMAKE_ARGS \
  -DFILE_CHECK_EXECUTABLE=$BUILD_PREFIX/libexec/llvm/FileCheck \
  -DCLANG_EXECUTABLE=$BUILD_PREFIX/bin/clang \
  -DCLANGPP_EXECUTABLE=$BUILD_PREFIX/bin/clang++ \
  -DLLVM_DIS_EXECUTABLE=$BUILD_PREFIX/bin/llvm-dis \
  -DLLVM_AS_EXECUTABLE=$BUILD_PREFIX/bin/llvm-as \
  -DARM_ENABLED=no \
  -DISPC_NO_DUMPS=ON \
  .. 
make -j${CPU_COUNT}
make install
