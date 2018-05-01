#!/bin/bash

export CPATH="${PREFIX}/include:${CPATH}"

cxxtestgen --version | fgrep -q "CxxTest version ${PKG_VERSION}."

cxxtestgen --error-printer -o runner.cpp doc/examples/MyTestSuite1.h

c++ -o runner runner.cpp
./runner
