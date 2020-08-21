#!/bin/bash

# Download Tensorflow first because 2.3.0 is not available on conda
if [ `uname` == "Linux" ]; then
    if [ "$PY_VER" == "3.6" ]; then
        python -m pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow_cpu-2.3.0-cp36-cp36m-manylinux2010_x86_64.whl
    fi
    if [ "$PY_VER" == "3.7" ]; then
        python -m pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow_cpu-2.3.0-cp37-cp37m-manylinux2010_x86_64.whl
    fi
    if [ "$PY_VER" == "3.8" ]; then
        python -m pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow_cpu-2.3.0-cp38-cp38-manylinux2010_x86_64.whl
    fi
fi
if [ `uname` == "Darwin" ]; then
    if [ "$PY_VER" == "3.6" ]; then
        python -m pip install https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-2.3.0-cp36-cp36m-macosx_10_9_x86_64.whl
    fi
    if [ "$PY_VER" == "3.7" ]; then
        python -m pip install https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-2.3.0-cp37-cp37m-macosx_10_9_x86_64.whl
    fi
    if [ "$PY_VER" == "3.8" ]; then
        python -m pip install https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-2.3.0-cp38-cp38-macosx_10_14_x86_64.whl
    fi
fi

python -c "import tensorflow as tf"

# Build
mkdir build && cd build
CXX=g++ CC=gcc cmake ..
make install
cd ..
