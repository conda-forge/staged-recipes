#!/bin/bash
mkdir build
cd build
export ISISROOT=$PWD
cmake -GNinja -DJP2KFLAG=ON -Dpybindings=OFF -DKAKADU_INCLUDE_DIR=/isisData/kakadu -DbuildTests=OFF -DCMAKE_BUILD_TYPE=Release -DISIS_BUILD_SWIG=ON -DCMAKE_INSTALL_PREFIX=$PREFIX ../isis/src/core
ninja install
cd ${SRC_DIR}/build/swig/python
python setup.py install
