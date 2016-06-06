#!/bin/bash

if [ `uname` == Darwin ]; then
    pythonw --sysroot=$PREFIX configure.py
else
    python --sysroot=$PREFIX configure.py
fi

make
make install
