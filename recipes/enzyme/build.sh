export LLVM_DIR=$PREFIX/lib/cmake/llvm
export LLVM_EXTERNAL_LIT=$PREFIX/bin/lit

cd enzyme
mkdir build
cd build

cmake -G Ninja -DLLVM_DIR=$LLVM_DIR -DLLVM_EXTERNAL_LIT=$LLVM_EXTERNAL_LIT -DCMAKE_INSTALL_PREFIX=$PREFIX ..
ninja

# Needed for tests to pass
#cp $PREFIX/libexec/llvm/FileCheck $PREFIX/bin/FileCheck

#ninja check-enzyme
ninja install
