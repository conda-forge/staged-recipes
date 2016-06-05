#!/bin/bash

if [ `uname` == Darwin ]; then
    pythonw configure.py
else
    python configure.py
fi

make
make install
