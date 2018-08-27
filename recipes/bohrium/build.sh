#!/bin/bash
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DEXT_VISUALIZER=OFF -D_GLIBCXX_USE_CXX11_ABI=0
make
make install
