#!/bin/bash

export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -lssl"

$PYTHON setup.py install