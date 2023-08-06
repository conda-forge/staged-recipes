#!/bin/bash

set -x

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  export PARALLEL="-DTPL_ENABLE_MPI=ON -DTPL_ENABLE_Pnetcdf=ON -DTPL_Netcdf_Enables_PNetcdf=ON"
else
  export PARALLEL="-DTPL_ENABLE_MPI=OFF"
fi

CMAKE_BUILD_TYPE=Release

mkdir build
cd build
cmake ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${BUILD_PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR:STRING="lib" \
  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DACCESSDIR:PATH=${PREFIX} \
  -DCMAKE_INSTALL_RPATH:PATH=${PREFIX}/lib \
  -DSeacas_ENABLE_SEACASExodus=ON \
  -DSeacas_ENABLE_SEACASExodus_for=ON \
  -DSeacas_ENABLE_SEACASExoIIv2for32=ON \
  -DSeacas_ENABLE_TESTS=OFF \
  -DSeacas_ENABLE_SEACASExodus=ON \
  -DSeacas_ENABLE_Fortran=ON \
  -DSeacas_ENABLE_SEACASExoIIv2for32=ON \
  -DSeacas_ENABLE_SEACASExodus_for=ON \
  -DSeacas_SKIP_FORTRANCINTERFACE_VERIFY_TEST=ON \
  -DSeacas_ENABLE_SEACASExodiff=ON \
  -DSeacas_ENABLE_SEACASExotxt=ON \
  -DTPL_ENABLE_Matio=OFF \
  -DTPL_ENABLE_Netcdf=ON \
  ${PARALLEL} \
  -DTPL_ENABLE_Pamgen=OFF \
  -DTPL_ENABLE_CGNS=OFF \
  -DTPL_ENABLE_HDF5=ON \
  -DSEACASExodus_ENABLE_SHARED=ON \
  ${SRC_DIR}
make install -j${CPU_COUNT} ${VERBOSE_CM}
