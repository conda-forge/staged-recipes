#! /bin/bash

set -e
set -x

cmake --build build --config Release -DSURELOG_USE_HOST_FLATBUFFERS=ON
cmake --install build --config Release
