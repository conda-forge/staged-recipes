#!/bin/sh

rm -rf build
mkdir build
cd build

Python3_NumPy_INCLUDE_DIR="$($PYTHON -c 'import numpy;print(numpy.get_include())')"
export GENERATE_PYTHON_STUBS=1
if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  export GENERATE_PYTHON_STUBS=0
fi

cmake ${CMAKE_ARGS} .. \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DPYTHON_EXECUTABLE=$PYTHON \
      -DPython3_NumPy_INCLUDE_DIR=$Python3_NumPy_INCLUDE_DIR \
      -DGENERATE_PYTHON_STUBS=$GENERATE_PYTHON_STUBS \
      -DBUILD_PYTHON_INTERFACE=ON \
      -DCOAL_HAS_QHULL=ON \
      -DBUILD_TESTING=OFF

ninja
ninja install
