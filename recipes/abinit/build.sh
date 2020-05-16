#!/bin/bash

# FFTW3
FFT_FLAVOR="none"

# Open BLAS
LINALG_FLAVOR="custom"
LINALG_LIBS="-L${PREFIX}/lib -lscalapack -llapack -lblas -lpthread"

NC_INCS="-I${PREFIX}/include"
NC_LIBS="-L${PREFIX}/lib -lnetcdff -lnetcdf -lhdf5_hl -lhdf5"

# LibXC library 
XC_INCS="-I${PREFIX}/include"
XC_LIBS="-L${PREFIX}/lib -lxcf90 -lxc"

CC=mpicc
if [[ -z "${OMPI_RELEASE_VERSION}" ]]; then  # mpich
  FC=mpif90
else  # openmpi
  FC="mpif90 -fopenmpi"
  export OMPI_MCA_plm=isolated
  export OMPI_MCA_btl_vader_single_copy_mechanism=none
  export OMPI_MCA_rmaps_base_oversubscribe=yes
fi

./config/scripts/makemake
./configure --prefix=${PREFIX} \
            --enable-mpi="yes" --enable-mpi-io="yes" \
            --with-linalg-flavor=${LINALG_FLAVOR} --with-linalg-libs="${LINALG_LIBS}" \
            --with-trio-flavor=netcdf \
            --with-netcdf-incs="${NC_INCS}" --with-netcdf-libs="${NC_LIBS}" \
            --with-dft-flavor="wannier90-fallback" \
            --enable-gw-dpc="yes" \
            --with-libxc-incs="${XC_INCS}" --with-libxc-libs="${XC_LIBS}"
make -j${CPU_COUNT}
make check 
make install-exec
