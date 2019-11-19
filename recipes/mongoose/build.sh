#!/bin/bash

export INSTALL="${PREFIX}"
# make sure CMake install goes in the right place
export CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib"

# make mongoose
make library static VERBOSE=1
make install VERBOSE=1
