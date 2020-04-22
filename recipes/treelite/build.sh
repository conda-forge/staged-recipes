#!/bin/bash

mkdir build
cd build
if [[ "$OSTYPE" == "darwin"* ]]; then
	find $PREFIX/include -name "omp.h"
	cmake .. -DOpenMP_CXX_INCLUDE_DIR=$PREFIX/include
else
	cmake ..
fi
make
cd ..
cd python
python setup.py install

