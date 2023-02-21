#!/bin/bash

set -ex
# test for presence of sql plugin
test -f $PREFIX/plugins/sqldrivers/libqsqlite${SHLIB_EXT}

cd test
ln -sf ${GXX} g++
cp ../xcrun .
cp ../xcodebuild .
export PATH=${PWD}:${PATH}
# To learn about qmake flags, read
# https://doc.qt.io/qt-5/qmake-variable-reference.html
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
