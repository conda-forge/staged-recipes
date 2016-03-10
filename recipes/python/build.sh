#!/bin/bash

# Brand the python.
python ${RECIPE_DIR}/brand_python.py

./configure --prefix=$PREFIX --enable-shared --without-ensurepip --enable-ipv6
make
make install

# Ensure that "python" can be called. We have environments for a reason.
cd $PREFIX/bin; ln -s python3 python
