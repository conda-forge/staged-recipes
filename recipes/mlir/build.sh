mkdir build
cd build

cmake ${CMAKE_ARGS} \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  ../mlir

make -j${CPU_COUNT}
