#!/bin/bash

# Test the installation of the library
test -e ${PREFIX}/include/semimap/semimap.h
test -e ${PREFIX}/test/test.cpp

# Compile and run the test suite
${CXX} ${CXXFLAGS} \
    -std=c++17 \
    -Wall \
    -I ${PREFIX}/include/semimap \
    ${PREFIX}/test/test.cpp \
    -o test_suite

./test_suite
rm ./test_suite
