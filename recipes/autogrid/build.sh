#!/bin/bash

#tar -xvf autodocksuite-4.2.6-x86_64Linux2.tar

export PATH="$BUILD_PREFIX/bin:$PATH"

# Debugging step: Check if csh is available
if ! command -v csh &> /dev/null; then
    echo "Error: csh is not available in the build environment."
    echo "PATH: $PATH"
    exit 1
fi

mkdir -p $PREFIX/bin


autoreconf -i

mkdir Linux

cd Linux
../configure
make

cp autogrid4 $PREFIX/bin
