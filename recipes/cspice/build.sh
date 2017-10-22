#!/bin/bash

cd ${SRC_DIR}/lib/

ar -x cspice.a
gcc -shared -fPIC -lm *.o -o libcspice.so

cd ${SRC_DIR}

cp lib/libcspice.so ${PREFIX}/lib
cp include/*.h ${PREFIX}/include
