#!/bin/bash

export LIBRARY_DIRS=${PREFIX}/lib
export INCLUDE_DIRS=${PREFIX}/include

$PYTHON setup.py install --single-version-externally-managed --record record.txt
