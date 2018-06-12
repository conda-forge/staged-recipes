#!/bin/bash

./configure --prefix="${PREFIX}" --with-libctl=no

make -j 2
pushd tests && make -j 2 check && popd
pushd libmeepgeom && make -j 2 check && popd
make install

rm ${SP_DIR}/meep/_meep.a
rm ${PREFIX}/lib/libmeep.a
rm ${PREFIX}/lib/libmeepgeom.a
