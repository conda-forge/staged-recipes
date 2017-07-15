#!/bin/bash

if [ "`uname`" == 'Darwin' ]
then
    # for Mac OSX
    export LIBARCHIVE="${PREFIX}/lib/libarchive.dylib"
else
    # for Linux
    export LIBARCHIVE="${PREFIX}/lib/libarchive.so"
fi
