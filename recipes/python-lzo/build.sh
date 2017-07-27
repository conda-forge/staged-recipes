#!/usr/bin/env bash

export CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/lzo $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"

$PYTHON setup.py install
