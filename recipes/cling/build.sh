#!/bin/bash

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      $SRC_DIR
make
make install

# Install kernelspec
cd $SRC_DIR/share/cling/Jupyter/kernel/
python $SRC_DIR/share/cling/Jupyter/kernel/setup.py install
jupyter kernelspec install $PREFIX/share/cling/Jupyter/kernel/cling-c++11 --sys-prefix
jupyter kernelspec install $PREFIX/share/cling/Jupyter/kernel/cling-c++14 --sys-prefix
jupyter kernelspec install $PREFIX/share/cling/Jupyter/kernel/cling-c++17 --sys-prefix
