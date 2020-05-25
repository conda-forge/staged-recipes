#!/bin/bash

./configure --prefix=$PREFIX \
   --with-linalg-libs="-L${PREFIX}/lib -lblas -llapack -lpthread" \
   --enable-libxc --with-libxc-incs="-I${PREFIX}/include" --with-libxc-libs="-L${PREFIX}/lib -lxcf90 -lxc" \
   IFLAGS="-I${SRC_DIR}/include -I${PREFIX}/finclude" \
   CC="${CC}" \
   FC="${FC}" \
   CFLAGS="${CFLAGS} -L${PREFIX}/lib -llapack -lblas -lxcf90 -lxc" \
   FFLAGS="${FFLAGS} -L${PREFIX}/lib -llapack -lblas -lxcf90 -lxc"

make -j1  # parallel make does not work
make install
make check
