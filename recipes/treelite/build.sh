#!/bin/bash

mkdir build
cd build
cmake ..
make
cd ..
cd python
python setup.py install

