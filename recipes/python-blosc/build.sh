#!/bin/bash

# export BLOSC_DIR=$PREFIX
# $PYTHON setup.py build_ext --inplace --blosc=$PREFIX
$PYTHON setup.py install --blosc=$PREFIX --single-version-externally-managed --record record.txt
