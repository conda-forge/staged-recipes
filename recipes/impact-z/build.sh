#!/usr/bin/env bash

# for cross compiling using openmpi
export OPAL_PREFIX=$PREFIX

if [[ "$target_platform" == osx* ]]; then
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
    # Hack around https://github.com/conda-forge/gfortran_osx-64-feedstock/issues/11
    # Taken from https://github.com/awvwgk/staged-recipes/tree/dftd4/recipes/dftd4
    # See contents of fake-bin/cc1 for an explanation
    export PATH="${PATH}:${RECIPE_DIR}/fake-bin"
fi

mkdir build
cd build

cmake \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DUSE_MPI=OFF \
    ../src

make -j${CPU_COUNT} VERBOSE=1 install

if [[ "$mpi" != "nompi" ]]; then
    export FFLAGS="$FFLAGS -std=legacy $LDFLAGS"
    export FC=mpifort

    cd ..
    mkdir build_mpi
    cd build_mpi
    cmake \
        ${CMAKE_ARGS} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DUSE_MPI=ON \
        ../src

    make -j${CPU_COUNT} VERBOSE=1 install
fi
