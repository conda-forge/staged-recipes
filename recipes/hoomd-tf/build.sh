#!/bin/bash

# Download Tensorflow first because 2.3.0 is not available on conda
if [ `uname` == "Linux" ]; then
    python -m pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow_cpu-2.3.0-cp38-cp38-manylinux2010_x86_64.whl
fi
if [ `uname` == "Darwin" ]; then
    python -m pip install https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-2.3.0-cp38-cp38-macosx_10_14_x86_64.whl
fi

python -c "import tensorflow as tf"

# Build
mkdir build && cd build
CXX=g++ CC=gcc cmake ..
make install
cd ..
