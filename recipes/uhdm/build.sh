#! /bin/bash

set -e
set -x

cmake --build build --config Release -DUHDM_USE_HOST_CAPNP=ON -DUHDM_USE_HOST_GTEST=ON
cmake --install build --config Release
