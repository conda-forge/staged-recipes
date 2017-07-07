#!/bin/bash

# prevent conflict between "LASzip" dir and 'laszip' executeable on OSX
# do doing build in a different directory
mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX -D CMAKE_BUILD_TYPE=Release ..

make install -j$CPU_COUNT
