#!/bin/bash

python3 builder/build_header.py ${PREFIX}/include/meos.h ${PREFIX}/lib/libmeos.so
python3 builder/build_pymeos_functions.py

python3 -m pip install . -vv