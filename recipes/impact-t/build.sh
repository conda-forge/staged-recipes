#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DUSE_MPI=OFF \
    ../src

make -j${CPU_COUNT} VERBOSE=1 install

if [[ "$mpi" != "nompi" ]]; then
     cd ..
     mkdir build_mpi
     cd build_mpi
     cmake \
         -DCMAKE_INSTALL_PREFIX=${PREFIX} \
         -DUSE_MPI=ON \
         ../src

     make -j${CPU_COUNT} VERBOSE=1 install
fi
