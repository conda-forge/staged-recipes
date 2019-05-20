#!/bin/bash

cd python
make pip
export plumed_default_kernel=$PREFIX/lib/libplumedKernel$SHLIB_EXT
$PYTHON -m pip install . --no-deps -vv

