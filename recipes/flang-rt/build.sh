#!/bin/bash
set -ex

MAJOR_VER=$(echo ${PKG_VERSION} | cut -d "." -f1)

mkdir build
cd build

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DLLVM_CONFIG_PATH=$BUILD_PREFIX/bin/llvm-config -DMLIR_TABLEGEN_EXE=$BUILD_PREFIX/bin/mlir-tblgen"
fi

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_Fortran_COMPILER=$BUILD_PREFIX/bin/flang \
    -DCMAKE_Fortran_COMPILER_WORKS=yes \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_MODULE_PATH=../cmake/Modules \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DLLVM_EXTERNAL_LIT=$PREFIX/bin/lit \
    -DLLVM_LIT_ARGS=-v \
    -DLLVM_CMAKE_DIR=$PREFIX/lib/cmake/llvm \
    -DLLVM_DIR=$PREFIX/lib/cmake/llvm \
    -DLLVM_ENABLE_RUNTIMES="flang-rt" \
    -DFLANG_RT_ENABLE_SHARED=ON \
    -DFLANG_RT_INCLUDE_TESTS=OFF \
    ../runtimes

cmake --build . -j2
cmake --install .

ln -s $PREFIX/lib/clang/$MAJOR_VER/lib/x86_64-unknown-linux-gnu/libflang_rt.runtime.a $PREFIX/lib/libflang_rt.runtime.a
ln -s $PREFIX/lib/clang/$MAJOR_VER/lib/x86_64-unknown-linux-gnu/libflang_rt.runtime.so $PREFIX/lib/libflang_rt.runtime.so

rm $PREFIX/compile_commands.json
