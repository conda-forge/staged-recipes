#! /bin/bash

set -e
set -x

cmake -DCMAKE_BUILD_TYPE=Release -DSURELOG_USE_HOST_FLATBUFFERS=ON -DSURELOG_USE_HOST_ANTLR=ON -DSURELOG_USE_HOST_UHDM=ON -DSURELOG_USE_HOST_GTEST=ON -B build .
cmake --build build --config Release
cmake --install build --config Release
