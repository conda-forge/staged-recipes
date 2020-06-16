#!/bin/bash

set -x
set -e

mkdir build
cd build
cmake .. -DENABLE_PROTOBUF=ON -GNinja
ninja install   # Install C++ library into Conda env
cd ../python
python setup.py install
cd ../runtime/python
python setup.py install
