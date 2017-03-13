#!/bin/bash

# build script for geoval installation

$PYTHON setup.py build_ext --inplace
$PYTHON setup.py build
$PYTHON setup.py install
