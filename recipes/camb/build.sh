#!/bin/bash

EXTRA_FFLAGS=-ffast-math make camb

make clean

cd pycamb
python setup.py build
