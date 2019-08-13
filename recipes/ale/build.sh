#!/bin/bash

set -e # Abort on error

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_TESTS=OFF ..
cmake --build . --target install
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
