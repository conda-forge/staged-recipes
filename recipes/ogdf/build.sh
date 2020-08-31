#!/bin/sh

mkdir build
cd build

if [ "$(uname)" == "Darwin" ]; then
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} -DBUILD_SHARED_LIBS=ON
else
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBUILD_SHARED_LIBS=ON
fi

make -j ${CPU_COUNT}
make install
