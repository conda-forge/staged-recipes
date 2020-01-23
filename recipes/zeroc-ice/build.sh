#!/bin/bash
export CPP_INCLUDE_PATH=$PREFIX/include
export CXX_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include
export LD_LIBRARY_PATH=$PREFIX/lib
$PYTHON -m pip install . --ignore-installed --no-deps -vv
ldd -r $PREFIX/lib/python*/site-packages/IcePy.so
