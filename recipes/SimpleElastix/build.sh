#!/usr/bin/env bash

# Tell the build to use conda's Python
SET PYTHON_EXECUTABLE=$PYTHON
SET PYTHON_INCLUDE_DIR=$PREFIX/include
SET PYTHON_LIBRARY=$PREFIX/lib

# Build
mkdir build
cd build
cmake ../SimpleElastix/SuperBuild
make -j4

# Install in Python
cd SimpleITK-build/Wrapping/PythonPackage
$PYTHON setup.py install
