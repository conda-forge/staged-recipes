#!/usr/bin/env bash
set -ex

if [ "${mpi}" != "nompi" ]; then
  MPI=yes
  SUFFIX="_onenode"
  export FC=mpifort CC=mpicc
else
  MPI=no
  SUFFIX=""
fi

conf_options=(
   "--prefix=${PREFIX}"
   "--with-mpi=${MPI}"
   "--disable-avx512"
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
../configure "${conf_options[@]}" --enable-openmp ..

make build -j 4
make check TEST_FLAGS="1500 50 16" OMP_NUM_THREADS=2 ELPA_DEFAULT_omp_threads=2
make install

# Create a pkg-config file without version suffix as well
cp ${PREFIX}/lib/pkgconfig/elpa${SUFFIX}_openmp-{${version},}.pc

popd
