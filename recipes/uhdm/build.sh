#! /bin/bash

set -e
set -x

cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_SHARED_LIBS=ON -DUHDM_USE_HOST_GTEST=ON -DUHDM_USE_HOST_CAPNP=ON -DPython_EXECUTABLE="$PYTHON" .
cmake --build build --config Release
cmake --install build --config Release
