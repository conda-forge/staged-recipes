#!/bin/bash

mkdir build
cd build
cmake-G "NMake Makefiles" DCMAKE_INSTALL_PREFIX=%PREFIX%\\Library ..
make install