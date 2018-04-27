#!/bin/bash

./configure --prefix="${PREFIX}" --with-libctl=no

make
pushd tests && make check && popd
pushd libmeepgeom && make check && popd
make install

rm ${SP_DIR}/meep/_meep.a
rm ${PREFIX}/lib/libmeep.a
rm ${PREFIX}/lib/libmeepgeom.a
