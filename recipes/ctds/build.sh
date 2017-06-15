#!/bin/bash

$PYTHON setup.py build_ext \
    --include-dirs=$PREFIX/include \
    --library-dirs=$PREFIX/lib

$PYTHON setup.py install
