#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record record.txt

cd $PREFIX/bin
rm -f pip2* pip3*
rm -f $SP_DIR/__pycache__/pkg_res*
