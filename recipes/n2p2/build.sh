#!/bin/bash
cd src
export CFLAGS=${CFLAGS}" -isystem $PREFIX/include/eigen3"
make -j${NUM_CPUS} libnnp libnnpif libnnptrain pynnp
mkdir -p ${PREFIX}/include ${PREFIX}/lib ${SP_DIR}
mv ${SRC_DIR}/src/pynnp/pynnp* ${SP_DIR}
cp ${SRC_DIR}/lib/* ${PREFIX}/lib
cp ${SRC_DIR}/include/* ${PREFIX}/include
