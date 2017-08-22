#!/bin/bash

[[ -d build ]] || mkdir build
cd build

QWT_INSTALL_PREFIX=$PREFIX qmake ../qwt.pro

make
make check
make install

# No test suite, but we can build examples in "examples/" as a check
echo "Building examples to test library install"
mkdir -p examples
cd examples/

qmake ../../examples/examples.pro
make

