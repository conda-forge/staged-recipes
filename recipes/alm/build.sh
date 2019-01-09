#!/bin/bash

cd python

export CPLUS_INCLUDE_PATH=$PREFIX/include:$PREFIX/include/eigen3:${CPLUS_INCLUDE_PATH}
export LIBRARY_PATH=$PREFIX/lib:${LIBRARY_PATH}
export CC=$CXX

if [ .$OSX_ARCH == . ]; then
    export LDFLAGS="-fopenmp -lblas"
else 
    export LDFLAGS="-fopenmp=libomp -lblas"
fi
echo $LDFLAGS

$PYTHON setup.py install --single-version-externally-managed --record record.txt

