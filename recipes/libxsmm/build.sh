#!/bin/bash
make -j${CPU_COUNT} CXX=$CXX CC=$CC FC=$FC PREFIX=${PREFIX} STATIC=0
make -j${CPU_COUNT} CXX=$CXX CC=$CC FC=$FC PREFIX=${PREFIX}
make -j${CPU_COUNT} CXX=$CXX CC=$CC FC=$FC PREFIX=${PREFIX} install
cp include/* ${PREFIX}/include
