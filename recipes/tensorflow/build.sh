#!/bin/bash

# install using pip from the whl file provided by Google

if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "2.7" ]; then
        pip install --no-deps https://storage.googleapis.com/tensorflow/mac/tensorflow-0.7.0-py2-none-any.whl
    else
        pip install --no-deps https://storage.googleapis.com/tensorflow/mac/tensorflow-0.7.0-py3-none-any.whl
    fi
fi

if [ `uname` == Linux ]; then
    if [ "$PY_VER" == "2.7" ]; then
        pip install --no-deps https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.7.0-py2-none-linux_x86_64.whl
    else
        pip install --no-deps https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.7.0-py3-none-linux_x86_64.whl
    fi
fi
