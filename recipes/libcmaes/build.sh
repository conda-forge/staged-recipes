#!/bin/sh

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

./autogen.sh
./configure --prefix=${PREFIX} --enable-python --enable-onlylib --with-eigen3-include=${PREFIX}/include/eigen3
make -j${CPU_COUNT}
make install
mv ${PREFIX}/lib/lcmaes.so ${SP_DIR}
${PYTHON} python/ptest.py
