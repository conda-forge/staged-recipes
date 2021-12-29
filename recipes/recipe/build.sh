#!/bin/bash
set -ex


if [[ "$mpi" == "nompi" ]]; then

cmake ${CMAKE_ARGS} -H. -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DENABLE_OPENMP=ON \
    -DHDF5_hdf5_fortran_LIBRARY=$PREFIX/lib/libhdf5${SHLIB_EXT}

else

cmake -H. -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DHDF5_hdf5_fortran_LIBRARY=$PREFIX/lib/libhdf5.dylib \
    -DENABLE_OPENMP=ON \
    -DENABLE_MPI=ON \
    -DENABLE_SCALAPACK=ON \
    -DSCALAPACK_LIBRARIES="-lscalapack"
fi


cmake --build build --target install
