#!/bin/bash
cd src
export CFLAGS=${CFLAGS}" -isystem $PREFIX/include/eigen3"
make -j${NUM_CPUS} libnnp libnnpif libnnptrain pynnp
mkdir -p ${PREFIX}/bin ${PREFIX}/lib
cp ${SRC_DIR}/lib/* ${PREFIX}/lib
make -j${NUM_CPUS} all-app
cp ${SRC_DIR}/bin/* ${PREFIX}/bin
