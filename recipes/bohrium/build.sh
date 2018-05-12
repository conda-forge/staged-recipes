#!/bin/bash
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DEXT_VISUALIZER=OFF
make
make install
