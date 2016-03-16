#!/usr/bin/env bash

export C_INCLUDE_PATH=$PREFIX/include  # required as fftw3.h installed here

$PYTHON setup.py build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt --optimize=1
