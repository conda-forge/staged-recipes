#!/bin/bash

if [ `uname` == Darwin ]; then
    LDFLAGS="$LDFLAGS -undefined dynamic_lookup -bundle"
fi

$PYTHON setup.py build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt


