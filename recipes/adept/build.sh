./configure --prefix=${PREFIX} --with-blas=openblas
make -j ${CPU_COUNT}
make check -j ${CPU_COUNT}
make install
