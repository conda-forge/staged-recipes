#!/usr/bin/env bash

# Build
mkdir build
cd build
cmake ../SuperBuild
make -j4

# Install in Python
cd SimpleITK-build/Wrapping/PythonPackage
$PYTHON setup.py install
