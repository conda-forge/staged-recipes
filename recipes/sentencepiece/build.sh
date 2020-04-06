#!/bin/bash

mkdir build && cd build
cmake ..
make -j $(nproc)
make install

cd ..
cd python

python setup.py build
python setup.py install  --single-version-externally-managed --record=record.txt
