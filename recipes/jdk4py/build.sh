#!/bin/bash

# install using pip from the wheel file on Pypi

if [ `uname` == Darwin ]; then
    pip install jdk4py==$PKG_VERSION --no-deps
fi

if [ `uname` == Linux ]; then
    pip install jdk4py==$PKG_VERSION --no-deps
fi
