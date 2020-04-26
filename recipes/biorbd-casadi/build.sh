#!/bin/bash
mkdir build
cd build

cmake ../ \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DMATH_LIBRARY_BACKEND="Casadi" \
      -DBUILD_EXAMPLE=OFF \
      -DMODULE_ACTUATORS=ON \
      -DMODULE_MUSCLES=ON \
      -DBINDER_PYTHON3=ON \
        -DNUMPY_INCLUDES=$PREFIX/numpy/core/include \
        -DPython3_EXECUTABLE=$PREFIX/bin/python \
      -DBINDER_MATLAB=OFF \
        -DMatlab_ezc3d_INSTALL_DIR=$PREFIX/MATLAB

make -j $CPU_COUNT
make install
