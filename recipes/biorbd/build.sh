#!/bin/bash
mkdir build
cd build

cmake ../ \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DBUILD_EXAMPLE=OFF \
      -DBINDER_PYTHON3=ON \
        -DNUMPY_INCLUDES=$PREFIX/numpy/core/include \
        -DPython_EXECUTABLE=$PREFIX/bin/python \
        -DPython3_EXECUTABLE=$PREFIX/bin/python \
      -DBINDER_MATLAB=OFF \
        -DMatlab_ezc3d_INSTALL_DIR=$PREFIX/MATLAB

make -j $CPU_COUNT
make install
