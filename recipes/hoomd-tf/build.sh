#!/bin/bash

# Download Tensorflow first because 2.3.0 is not available on conda
python -m pip install tensorflow==2.3.0
python -c "import tensorflow as tf"

# Build
mkdir build && cd build
CXX=g++ CC=gcc cmake ..
make install
cd ..
