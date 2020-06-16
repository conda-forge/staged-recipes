#!/bin/bash

set -x
set -e

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="$PREFIX" -DENABLE_PROTOBUF=ON -GNinja
ninja install   # Install C++ library into Conda env
cd ../python
python setup.py install --single-version-externally-managed --record=record.txt
cd ../runtime/python
python setup.py install --single-version-externally-managed --record=record.txt
