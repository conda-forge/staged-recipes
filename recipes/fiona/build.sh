#!/bin/bash

$PYTHON setup.py build_ext -I$PREFIX/include -L$PREFIX/lib -lgdal install --single-version-externally-managed --record record.txt
