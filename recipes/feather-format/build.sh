#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # Building Feather requires a C++11 compiler, which requires OS X 10.9+
    export MACOSX_DEPLOYMENT_TARGET=10.8
fi

$PYTHON setup.py install --single-version-externally-managed --record record.txt
