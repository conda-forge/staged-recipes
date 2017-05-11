#!/bin/bash
export CFLAGS="-I$PREFIX/include ${CFLAGS}"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib ${LDFLAGS}"
$PYTHON setup.py build --enable-all-extensions
$PYTHON setup.py install --single-version-externally-managed --record record.txt
$PYTHON setup.py test
