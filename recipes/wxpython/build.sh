#!/bin/bash

## build script tested on OS-X

echo "Running OS-X Build Script"

cd wxPython
$PYTHON build-wxpython.py --prefix=$PREFIX --build_dir=../bld --osx_cocoa --install
