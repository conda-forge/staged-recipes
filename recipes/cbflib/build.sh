#!/bin/bash

set -e

# Regenerate the python bindings with an up-to-date swig
(
    cd pycbf
    echo "Regenerating pycbf.py and pycbf_wrap.c"
    swig -python pycbf.i
)

cp ${RECIPE_DIR}/CMakeLists.txt .
cp ${RECIPE_DIR}/setup.py.in pycbf/

# HDF5 currently has no shared fortran libraries on macOS
USE_FORTRAN=no
if [[ $(uname) == "Linux" ]]; then
  USE_FORTRAN=yes
fi

mkdir -p _build
cd _build
cmake .. -GNinja \
    -DBUILD_TESTING=no \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$CONDA_PREFIX \
    -DPython_ROOT_DIR=$PREFIX -DPython_FIND_STRATEGY=LOCATION \
    -DUSE_TIFF=no \
    -DBUILD_PYCBF=yes \
    -DUSE_FORTRAN=${USE_FORTRAN}
ninja install
