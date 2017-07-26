#!/bin/bash

if [ "`uname`" == 'Darwin' ]
then
    # for Mac OSX
    export LIBARCHIVE="${CONDA_PREFIX}/lib/libarchive.dylib"
else
    # for Linux
    export LIBARCHIVE="${CONDA_PREFIX}/lib/libarchive.so"
fi
