#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # Building Feather requires a C++11 compiler, which requires OS X 10.9+
    export MACOSX_DEPLOYMENT_TARGET=10.7
    export CFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
fi

$PYTHON setup.py install --single-version-externally-managed --record record.txt
