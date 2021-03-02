#!/bin/bash

$CC -I"${PREFIX}/include" -L"${PREFIX}/lib" sqrt.c -o sqrt -Wl,-rpath,"${PREFIX}/lib" -lmpdec || exit 1
./sqrt || exit 1


$CXX -I"${PREFIX}/include" -L"${PREFIX}/lib" sqrt.cc -std=c++11 -o sqrt -Wl,-rpath,"${PREFIX}/lib" -lmpdec++ -lmpdec || exit 1
./sqrt
