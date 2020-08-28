#!/bin/sh

mkdir build
cd build

if [ "$(uname)" == "Darwin" ]; then
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}
else
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX}
fi

make -j4
make install
