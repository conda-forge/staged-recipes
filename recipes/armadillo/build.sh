#!/usr/bin/env bash

mkdir -p build
cd build

if [[ `uname` == 'Darwin' ]]; then

    cmake .. \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_MACOSX_RPATH="ON" \
        -DCMAKE_INSTALL_RPATH="${PREFIX}/lib"
    #    -DDETECT_HDF5="true"

else

    cmake .. \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    #    -DDETECT_HDF5="true"
fi

make
make install
cd ${SRC_DIR}/tests && make && ./main
