#!/bin/bash

wget https://www.dropbox.com/s/uu5henbqn9ifn1h/CUDA_SIMrecon_dependencies.zip
unzip CUDA_SIMrecon_dependencies.zip

mkdir cmake_build
cd cmake_build
cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release ..
make
make install
