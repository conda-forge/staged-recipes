#!/bin/bash -e
cmake ${CMAKE_ARGS} -S ${SRC_DIR} -B build \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_CXX_STANDARD=${root_cxx_standard} \
    -DGeant4VMC_USE_VGM=ON
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
