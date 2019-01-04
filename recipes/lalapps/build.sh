#!/bin/bash

./configure \
	--prefix=${PREFIX} \
	--disable-gcc-flags \
	--enable-cfitsio \
	--enable-openmp \
	--enable-mpi \
	MPICC=${PREFIX}/bin/mpicc \
	MPICXX=${PREFIX}/bin/mpicxx \
	MPIFC=${PREFIX}/bin/mpifc

make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check
make -j ${CPU_COUNT} install
