#! /bin/bash

set -e
set -x

cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DUHDM_USE_HOST_GTEST=ON -DUHDM_USE_HOST_CAPNP=ON .
cmake --build build --config Release
cmake --install build --config Release
