#!/bin/bash

CPPFLAGS="-I$PREFIX/include -L$PREFIX/lib" $PYTHON setup.py install
