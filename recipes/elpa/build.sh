#!/usr/bin/env bash
set -ex

if [ "${mpi}" != "nompi" ]; then
  MPI=yes
  SUFFIX="_onenode"
  FC=mpifort
  CC=mpicc
else
  MPI=no
  SUFFIX=""
fi

# Use full optimization
CFLAGS="${CFLAGS//-O2/-O3} -mavx2 -mfma -funsafe-loop-optimizations -funsafe-math-optimizations -ftree-vect-loop-version"
FFLAGS="${FFLAGS//-O2/-O3} -mavx2 -mfma"

conf_options=(
   "--prefix=${PREFIX}"
   "--with-mpi=${MPI}"
   "--disable-avx512"
   "FC=\"${FC}\""
   "CC=\"${CC}\""
   "FFLAGS=\"${FFLAGS}\""
   "CFLAGS=\"${CFLAGS}\""
   "LDFLAGS=\"${LDFLAGS}\""
)

mkdir build
pushd build
../configure "${conf_options[@]}" ..

make build -j 4
make check TEST_FLAGS="1500 50 16"
make install

# Create a pkg-config file without version suffix as well
cp ${PREFIX}/lib/pkgconfig/elpa${SUFFIX}-{${version},}.pc

popd

mkdir build_openmp
pushd build_openmp
../configure --enable-openmp "${conf_options[@]}" ..

make build -j 4
make check TEST_FLAGS="1500 50 16" OMP_NUM_THREADS=2 ELPA_DEFAULT_omp_threads=2
make install

# Create a pkg-config file without version suffix as well
cp ${PREFIX}/lib/pkgconfig/elpa${SUFFIX}_openmp-{${version},}.pc

popd
