#!/bin/bash

# make sure CMake install goes in the right place
export INSTALL="${PREFIX}"
export CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib"

# make SuiteSparse
make library static VERBOSE=1
make install VERBOSE=1
