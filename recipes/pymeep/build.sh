#!/bin/bash

./configure --prefix="${PREFIX}" --with-libctl=no

make
make check
make install

rm ${SP_DIR}/meep/_meep.a
rm ${PREFIX}/lib/libmeep.a
rm ${PREFIX}/lib/libmeepgeom.a
