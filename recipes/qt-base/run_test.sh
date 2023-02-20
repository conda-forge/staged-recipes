#!/bin/bash

set -ex

ls
cd test
ln -sf ${GXX} g++
cp ../xcrun .
cp ../xcodebuild .
export PATH=${PWD}:${PATH}
qmake                         \
    QMAKE_CXX="${CXX}"        \
    QMAKE_LINK="${CXX}"       \
    QMAKE_LFLAGS="${LDFLAGS}" \
    hello.pro
make
./hello
# Only test that this builds
make clean

qmake                         \
    QMAKE_CXX="${CXX}"        \
    QMAKE_LINK="${CXX}"       \
    QMAKE_LFLAGS="${LDFLAGS}" \
    test_qmimedatabase.pro
make
./test_qmimedatabase
make clean
