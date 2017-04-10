# explicitly link mpi, openblas
export LDFLAGS="-L$PREFIX/lib -lmpi -lopenblas $LDFLAGS"

cd src/cmbuild
cmake \
    -DHYPRE_SHARED=ON \
    -DHYPRE_USING_HYPRE_BLAS=OFF \
    -DHYPRE_USING_HYPRE_LAPACK=OFF \
    -DHYPRE_USING_FEI=OFF \
    -DHYPRE_INSTALL_PREFIX="$PREFIX" \
    ..

make -j${NUM_CPUS}
make install
