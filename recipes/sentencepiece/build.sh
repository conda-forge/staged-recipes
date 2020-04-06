#!/bin/bash

mkdir build && cd build

export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

cmake ..
make -j $(nproc)
make install

cd ..
cd python

python setup.py build
python setup.py install  --single-version-externally-managed --record=record.txt
