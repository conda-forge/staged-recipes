#! /bin/bash

set -e
set -x

cmake -DCMAKE_BUILD_TYPE=Release -DUHDM_USE_HOST_CAPNP=ON -DUHDM_USE_HOST_GTEST=on -B build .
cmake --build build --config Release
cmake --install build --config Release
