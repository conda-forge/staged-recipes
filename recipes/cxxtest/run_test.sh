#!/bin/bash

export CPATH="${PREFIX}/include:${CPATH}"

cxxtestgen --version | fgrep -q "CxxTest version ${PKG_VERSION}."

cxxtestgen --error-printer -o runner.cpp doc/examples/MyTestSuite1.h

echo "***** c++"
c++ --version
echo "***** PREFIX/include"
echo ${PREFIX}/include
ls -l ${PREFIX}/include
echo "***** BUILDING runner.cpp"
c++ -o runner -I${PREFIX}/include runner.cpp
echo "***** EXECUTING TESTS"
./runner
