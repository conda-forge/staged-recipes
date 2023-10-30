#!/bin/bash
export CLICOLOR_FORCE=1

mkdir -p build
cd build

if [[ "$mpi" == "nompi" ]]; then
  on_mpi="OFF"
else
  on_mpi="ON"
fi

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
    build_type="Debug"
else
    build_type="Release"
    echo "Debugging Disabled"
fi

cmake .. \
    -DCMAKE_BUILD_TYPE="Release" \
    -DPYTHON_ROOT_DIR="${PREFIX}" \
    -Wno-dev \
    -DCONFIGURATION_ROOT_DIR="${SRC_DIR}/deps/config" \
    -DSALOME_CMAKE_DEBUG=ON \
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
    -DPYTHON_EXECUTABLE:FILEPATH="$PYTHON" \
    -DHDF5_ROOT_DIR="${PREFIX}" \
    -DSWIG_ROOT_DIR="${PREFIX}" \
    -DMEDFILE_ROOT_DIR="${PREFIX}" \
    -DSCOTCH_ROOT_DIR="${PREFIX}" \
    -DMETIS_ROOT_DIR="${PREFIX}" \
    -DPARMETIS_ROOT_DIR="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    ${CMAKE_ARGS}

make -j$CPU_COUNT
make install
