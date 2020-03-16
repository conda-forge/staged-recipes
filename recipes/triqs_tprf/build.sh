#!/usr/bin/env bash

mkdir build
cd build

# Openmpi Specific environment setup - Cf. https://github.com/conda-forge/libnetcdf-feedstock/pull/80
export OMPI_MCA_btl=self,tcp
export OMPI_MCA_plm=isolated
export OMPI_MCA_rmaps_base_oversubscribe=yes
export OMPI_MCA_btl_vader_single_copy_mechanism=none
mpiexec="mpiexec --allow-run-as-root"

source $PREFIX/share/triqsvars.sh

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    ..

make -j${CPU_COUNT} VERBOSE=1
CTEST_OUTPUT_ON_FAILURE=1 ctest
make install
