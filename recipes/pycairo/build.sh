#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record record.txt

ln -s $PREFIX/include/pycairo/py3cairo.h $PREFIX/include/pycairo/pycairo.h
