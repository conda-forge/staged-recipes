#!/bin/bash

$PYTHON setup.py install 

ln -s $PREFIX/include/pycairo/py3cairo.h $PREFIX/include/pycairo/pycairo.h
