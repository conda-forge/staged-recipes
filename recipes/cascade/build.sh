#!/usr/bin/env bash

mkdir build
cd build

cmake -G "Ninja" \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPython3_EXECUTABLE=$PREFIX/bin/python \
    -DPython3_NumPy_INCLUDE_DIR=`python -c "import numpy as np;print(np.get_include())"` \
    -DCMAKE_BUILD_TYPE=Release \
    -DCASCADE_BUILD_TESTS=no \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCASCADE_BUILD_PYTHON_BINDINGS=yes \
    ..

cmake --build . -- -v
cmake --build . --target install
