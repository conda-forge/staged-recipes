#!/bin/bash

EXTRA_CMAKE_ARGS=""
if [[ `uname` == 'Darwin' ]];
then
    EXTRA_CMAKE_ARGS="-DLLVM_ENABLE_LIBCXX=ON"
else
    EXTRA_CMAKE_ARGS="-DLLVM_ENABLE_LIBCXX=OFF"
fi
export EXTRA_CMAKE_ARGS

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      ${EXTRA_CMAKE_ARGS} \
      $SRC_DIR

make
make install

# Install kernelspec
cd $SRC_DIR/tools/Jupyter/kernel/
python $SRC_DIR/tools/Jupyter/kernel/setup.py install
jupyter kernelspec install $PREFIX/share/cling/Jupyter/kernel/cling-c++11 --sys-prefix
jupyter kernelspec install $PREFIX/share/cling/Jupyter/kernel/cling-c++14 --sys-prefix
jupyter kernelspec install $PREFIX/share/cling/Jupyter/kernel/cling-c++17 --sys-prefix
