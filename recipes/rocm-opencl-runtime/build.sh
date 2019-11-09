#!/bin/bash


mkdir -p compiler/llvm/tools/clang/lib/Headers/
cp $PREFIX/lib/clang/*/include/opencl-c.h compiler/llvm/tools/clang/lib/Headers/

mkdir build
cd build

export CC=$PREFIX/bin/clang
export CXX=$PREFIX/bin/clang++
export CONDA_BUILD_SYSROOT=$PREFIX/$HOST/sysroot

cmake \
  -DLLVM_DIR=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DUSE_COMGR_LIBRARY=yes \
  ..

make VERBOSE=1 -j${CPU_COUNT}
make install

mkdir -p $PREFIX/etc/OpenCL/vendors
echo $PREFIX/lib/x86_64/libamdocl64.so > $PREFIX/etc/OpenCL/vendors/amdocl64.icd

rm -rf $PREFIX/lib/libOpenCL.so*

