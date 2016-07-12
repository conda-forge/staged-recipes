#!/bin/bash

export USE_CYTHON=True

$PYTHON setup.py build_ext -I$PREFIX/include \
                 install --single-version-externally-managed --record record.txt
