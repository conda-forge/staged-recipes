#!/bin/bash
set -ex

mkdir build
cd build

export MPIEXEC_MAX_NUMPROCS=4

cmake .. \
 -DCMAKE_INSTALL_PREFIX=${PREFIX} \
 -DENABLE_TESTS=ON

cmake --build . --target install

export OMPI_MCA_plm_rsh_agent=sh

CTEST_OUTPUT_ON_FAILURE=ON TESTS="global/testing/test.x global/testing/testc.x global/testing/testmatmult.x global/testing/patch.x global/testing/simple_groups_comm.x global/testing/elempatch.x" make test
