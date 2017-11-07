#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    
    cd build
    cmake -DCMAKE_{C,CXX}_FLAGS="-arch x86_64" -DCMAKE_Fortran_FLAGS="-m64" -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DCMAKE_EXE_LINKER_FLAGS='-headerpad_max_install_names' ..
    make
    make install
    
fi

if [ "$(uname)" == "Linux" ]; then

    cd build
    cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DLAPACK_LIBRARIES=${PREFIX}/lib/liblapack.so -DBLAS_LIBRARIES=${PREFIX}/lib/libcblas.so ..
    make
    make install

fi
