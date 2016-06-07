#!/bin/bash

if [ `uname` == Darwin ]; then
    pythonw configure.py --sysroot=$PREFIX
else
    python configure.py --sysroot=$PREFIX
fi

make
make install
