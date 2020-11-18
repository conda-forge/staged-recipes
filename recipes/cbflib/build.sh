#!/bin/bash

set -e

# Regenerate the python bindings with an up-to-date swig
(
    cd pycbf
    echo "Regenerating pycbf.py and pycbf_wrap.c"
    swig -python pycbf.i
)


mkdir -p _build
cd _build
cmake .. -GNinja \
    -DBUILD_TESTING=no \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$CONDA_PREFIX \
    -DPython_ROOT_DIR=$PREFIX -DPython_FIND_STRATEGY=LOCATION \
    -DUSE_TIFF=no \
    -DBUILD_PYCBF=yes \
    -DUSE_FORTRAN=no
ninja install
