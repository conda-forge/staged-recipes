#!/bin/bash
make -j${CPU_COUNT} CXX=$CXX CC=$CC FC=$FC PREFIX=${PREFIX}
make -j${CPU_COUNT} CXX=$CXX CC=$CC FC=$FC PREFIX=${PREFIX} install
