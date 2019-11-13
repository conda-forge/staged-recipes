#!/bin/bash

# Setup CMake build location
rm -rf build
mkdir build
cd build

# MPI variants
if [[ ${mpi} == "nompi" ]]; then
   export ENABLE_MPI="OFF"
else
   export ENABLE_MPI="ON"
fi

# configure with cmake
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DENABLE_PYTHON=ON \
      -DPYTHON_EXECUTABLE:FILEPATH=$(which ${PYTHON}) \
      -DENABLE_FORTRAN=ON \
      -DENABLE_MPI=$ENABLE_MPI \
      -DPYTHON_MODULE_INSTALL_PREFIX=${SP_DIR} \
      -DHDF5_DIR=${PREFIX} \
      ../src

# build, test, and install
make

###############################################
# skip running tests during build if mpi is on
# 
# rsh/ssh don't exist in build containers
# so mpiexec fails to launch our tests
###############################################
if [[ ${ENABLE_MPI} == "OFF" ]]; then
     env CTEST_OUTPUT_ON_FAILURE=1 make test
fi

make install
