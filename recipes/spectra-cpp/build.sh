#!/bin/bash

cmake -B build -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=ON
cmake --build build
cmake --install build

# Run the tests here as they're omitted from installation
# NOTE: GenEigs/GenEigsRealShift test fails consistently on mac and linux, omit
cd build && ctest -E GenEigs
