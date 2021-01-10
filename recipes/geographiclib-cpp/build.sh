#! /bin/sh -e
mkdir -p build && cd build
cmake \
    -DGEOGRAPHICLIB_LIB_TYPE=SHARED \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INCLUDE_PATH=${CONDA_PREFIX}/include \
    -DCMAKE_LIBRARY_PATH=${CONDA_PREFIX}/lib \
    ..

make -j$CPU_COUNT
make install
