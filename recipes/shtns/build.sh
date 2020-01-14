#!/bin/bash
SHTNS="shtns-3.3.1-r694"
cd src
./configure --enable-python --disable-openmp --enable-mkl
make
${PYTHON} setup.py install -v
