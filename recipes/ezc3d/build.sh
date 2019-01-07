#!/bin/bash
mkdir build
cd build

cmake ../ \
    -DNUMPY_INCLUDES=$PREFIX/numpy/core/include \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_EXAMPLE=OFF \
    -DBINDER_MATLAB=OFF \
    -DMatlab_ezc3d_INSTALL_DIR=$PREFIX/MATLAB \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPython_EXECUTABLE=$PREFIX/bin/python \
    -DPython3_EXECUTABLE=$PREFIX/bin/python \
    -DBINDER_PYTHON3=ON

make -j $CPU_COUNT
make install
