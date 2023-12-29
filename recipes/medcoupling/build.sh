#!/bin/bash

set -ex

mkdir -p build
cd build

if [[ "$mpi" == "nompi" ]]; then
  on_mpi="OFF"
else
  on_mpi="ON"
fi

# remove the share cmake files
find ${PREFIX}/share/cmake -type d -name "medfile-*" -exec rm -rf {} +

cmake .. \
    -DCMAKE_BUILD_TYPE="Release" \
    -DPYTHON_ROOT_DIR="${PREFIX}" \
    -DPYTHON_EXECUTABLE:FILEPATH="$PYTHON" \
    -Wno-dev \
    -DCONFIGURATION_ROOT_DIR="${SRC_DIR}/deps/config" \
    -DSALOME_CMAKE_DEBUG=ON \
    -DMED_INT_IS_LONG=ON \
    -DSALOME_USE_MPI=${on_mpi} \
    -DMEDCOUPLING_BUILD_TESTS=OFF \
    -DMEDCOUPLING_BUILD_DOC=OFF \
    -DMEDCOUPLING_USE_64BIT_IDS=ON \
    -DMEDCOUPLING_USE_MPI=${on_mpi} \
    -DMEDCOUPLING_MEDLOADER_USE_XDR=OFF \
    -DXDR_INCLUDE_DIRS="" \
    -DMEDCOUPLING_PARTITIONER_PARMETIS=OFF \
    -DMEDCOUPLING_PARTITIONER_METIS=OFF \
    -DMEDCOUPLING_PARTITIONER_SCOTCH=OFF \
    -DMEDCOUPLING_PARTITIONER_PTSCOTCH=${on_mpi} \
    -DMPI_C_COMPILER:PATH="$(which mpicc)" \
    ${CMAKE_ARGS}

make -j$CPU_COUNT
make install
