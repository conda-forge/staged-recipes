#!/bin/bash

set -e

ls
cd test
ln -s ${GXX} g++
cp ../xcrun .
cp ../xcodebuild .
export PATH=${PWD}:${PATH}
qmake hello.pro
make
./hello
# Only test that this builds
make clean

qmake test_qmimedatabase.pro
make
./test_qmimedatabase
make clean
