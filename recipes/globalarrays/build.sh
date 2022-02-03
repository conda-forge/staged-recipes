#!/bin/bash
set -ex

mkdir build
cd build

export MPIEXEC_MAX_NUMPROCS=2

cmake .. \
 -DCMAKE_INSTALL_PREFIX=${PREFIX} \
 -DENABLE_TESTS=ON

cmake --build . --target install

export OMPI_MCA_plm_rsh_agent=sh

CTEST_OUTPUT_ON_FAILURE=ON make test
