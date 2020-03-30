#!/bin/bash

# install using pip from the wheel file on Pypi

if [ `uname` == Darwin ]; then
    pip install https://files.pythonhosted.org/packages/dd/6f/6298041ce3310261491ed5b319ef99b276051b6b2f48d8e9297aefbe3f32/jdk4py-11.0.5.0-py3-none-macosx_10_9_x86_64.whl --no-deps
fi

if [ `uname` == Linux ]; then
    pip install https://files.pythonhosted.org/packages/e1/13/1516d447f9e0665ede074a18ccec32c78f256e639007774128cce0b2fe19/jdk4py-11.0.5.0-py3-none-manylinux1_x86_64.whl --no-deps
fi
