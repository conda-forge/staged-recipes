#!/usr/bin/env bash
set -ex

echo "**************** F R E E F E M  B U I L D  S T A R T S  H E R E ****************"

autoreconf -i
export FFLAGS=-fallow-argument-mismatch
# Required to make linker look in correct prefix
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

./configure --prefix=$PREFIX \
            --enable-optim \
            --enable-debug \
            --disable-scotch \
            --without-mpi \
            --with-hdf5=$PREFIX/bin/h5cc \
            --disable-tetgen --disable-lapack --disable-metis --disable-parmetis --disable-mmg3d --disable-mmg --disable-parmmg --disable-mshmet --disable-gmm --disable-ipopt --disable-scalapack --disable-mumps --disable-mumps_seq --disable-nlopt --disable-scotch --disable-superlu --disable-umfpack --disable-yams --disable-pipe --disable-libpthread_google --disable-MMAP --disable-NewSolver --disable-mkl --disable-hpddm --disable-bem \
            --without-petsc --without-flib --without-glut --without-petsc --without-petsc_complex --without-cadna \
            --disable-c --disable-fortran
            #--with-hdf5=$PREFIX/lib/libhdf5.so \
            #--with-hdf5-include=$PREFIX/include \
            #--with-blas=$BUILD_PREFIX/lib/libopenblas.so.0 \
            #--with-blas-include=$BUILD_PREFIX/include \
            #--without-arpack

make -j $CPU_COUNT
make -j # $CPU_COUNT check
make install
rm $PREFIX/lib/ff++/4.11/lib/*.so

echo "**************** F R E E F E M  B U I L D  E N D S  H E R E ****************"
