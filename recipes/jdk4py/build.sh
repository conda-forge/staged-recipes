#!/bin/bash

# install using pip from the wheel file on Pypi

if [ `uname` == Darwin ]; then
    pip install https://files.pythonhosted.org/packages/31/78/000412bf83e151ed3d1f669dc7371cab8afdbdd28e3adaffe0d0b3abf5ae/jdk4py-11.0.5.1-py3-none-macosx_10_9_x86_64.whl --no-deps
fi

if [ `uname` == Linux ]; then
    pip install https://files.pythonhosted.org/packages/17/20/20bdc49ce3b961b093fd57a710e5776f62a7c5306b13b6ecd9c0eef3e5fb/jdk4py-11.0.5.1-py3-none-manylinux1_x86_64.whl --no-deps
fi
