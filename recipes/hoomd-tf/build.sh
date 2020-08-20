#!/bin/bash

# Download Tensorflow first because 2.3.0 is not available on conda
python -m pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow_cpu-2.3.0-cp37-cp37m-manylinux2010_x86_64.whl -v 
python -c "import tensorflow as tf"

# Build
mkdir build && cd build
CXX=g++ CC=gcc cmake ..
make install
cd ..
