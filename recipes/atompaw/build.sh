#!/bin/bash

./configure --prefix=$PREFIX \
   --with-linalg-libs="-L${PREFIX}/lib -lblas -llapack -lpthread" \
   IFLAGS="-I${SRC_DIR}/include -I${PREFIX}/finclude" \
   CC="${CC}" \
   FC="${FC}" \
   CFLAGS="${CFLAGS} -L${PREFIX}/lib -llapack -lblas" \
   FFLAGS="${FFLAGS} -L${PREFIX}/lib -llapack -lblas"

make -j1  # parallel make does not work
make install
make check
