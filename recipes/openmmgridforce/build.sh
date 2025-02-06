#!/bin/bash

mkdir build
cd build

# Configure build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DOPENMM_DIR=$PREFIX 

# Build in parallel
make -j$CPU_COUNT
make install

# Build Python wrappers
cd ../python
swig -python -c++ -o GridForcePluginWrapper.cpp -I$PREFIX/include gridforceplugin.i
$PYTHON setup.py build
$PYTHON setup.py install
