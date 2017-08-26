#!/bin/bash 
$PYTHON setup.py build_ext -I${PREFIX}/include -L${PREFIX}/lib install --single-version-externally-managed --record record.txt
$PYTHON setup.py install --single-version-externally-managed --record record.txt

