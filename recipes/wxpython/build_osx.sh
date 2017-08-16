#!/bin/bash

## build script tested on OS-X

cd wxPython
$PYTHON build-wxpython.py --prefix=$PREFIX --build_dir=../bld --osx_cocoa --install
