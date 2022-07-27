#!/usr/bin/env bash

set -ex

export \
    OMPI_MCA_plm=isolated \
    OMPI_MCA_btl_vader_single_copy_mechanism=none \
    OMPI_MCA_rmaps_base_oversubscribe=yes

mkdir _build
pushd _build

../configure \
    --prefix=$PREFIX \
    --enable-shared \
    --with-mpi \
    --with-blas="$PREFIX/lib/libblas.so" \
    --with-lapack="$PREFIX/lib/liblapack.so" \
    --with-scalapack="$PREFIX/lib/libscalapack.so"

popd

make -C _build -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:0}" == "0" ]]; then
    make -C _build check MPIEXEC="mpiexec -np 2"
fi
make -C _build install
