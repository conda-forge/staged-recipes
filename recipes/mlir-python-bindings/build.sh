#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export CFLAGS="${CFLAGS//-fno-plt/}"
  export CXXFLAGS="${CXXFLAGS//-fno-plt/}"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DLLVM_TABLEGEN_EXE=$BUILD_PREFIX/bin/llvm-tblgen -DNATIVE_LLVM_DIR=$BUILD_PREFIX/lib/cmake/llvm"
  CMAKE_ARGS="${CMAKE_ARGS} -DCROSS_TOOLCHAIN_FLAGS_NATIVE=-DCMAKE_C_COMPILER=$CC_FOR_BUILD;-DCMAKE_CXX_COMPILER=$CXX_FOR_BUILD;-DCMAKE_C_FLAGS=-O2;-DCMAKE_CXX_FLAGS=-O2;-DCMAKE_EXE_LINKER_FLAGS=\"-L$BUILD_PREFIX/lib\";-DCMAKE_MODULE_LINKER_FLAGS=;-DCMAKE_SHARED_LINKER_FLAGS=;-DCMAKE_STATIC_LINKER_FLAGS=;-DCMAKE_AR=$(which ${AR});-DCMAKE_RANLIB=$(which ${RANLIB});-DZLIB_ROOT=${BUILD_PREFIX}"
else
  rm -rf $BUILD_PREFIX/bin/llvm-tblgen
fi

mkdir -p build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_BUILD_TOOLS=ON \
  -DLLVM_BUILD_UTILS=ON \
  -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
  -DPython3_EXECUTABLE="$PYTHON" \
  -GNinja \
  ../mlir

ninja
ninja install

cd $PREFIX

mkdir -p $SP_DIR
mv $PREFIX/python_packages/mlir_core/mlir $SP_DIR/

rm -rf $PREFIX/src $PREFIX/python_packages
