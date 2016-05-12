#!/usr/bin/env bash

# Build
mkdir build
cd build
cmake ../SuperBuild
make -j4

# Install in Python
$PYTHON ./SimpleITK-build/Wrapping/PythonPackage/setup.py install
