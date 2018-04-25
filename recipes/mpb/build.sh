#!/bin/bash

./configure --prefix="${PREFIX}" --enable-shared --with-libctl=no --with-hermitian-eps

make

if [ `uname` == Darwin ]; then
    install_name_tool -add_rpath ${PREFIX}/lib ${SRC_DIR}/tests/.libs/blastest
    install_name_tool -add_rpath ${PREFIX}/lib ${SRC_DIR}/tests/.libs/maxwell_test
    install_name_tool -add_rpath ${PREFIX}/lib ${SRC_DIR}/tests/.libs/eigs_test
fi

make check
make install

rm ${PREFIX}/lib/libmpb.a
