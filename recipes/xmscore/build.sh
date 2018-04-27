#!/bin/bash
mkdir -p build
cd build
${BUILD_PREFIX}/bin/cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=True -DIS_CONDA_BUILD=True ..
make -j${CPU_COUNT}
make install
