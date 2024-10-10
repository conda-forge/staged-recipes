#!/bin/bash

set -exo pipefail

export CMAKE_ARGS="\
    -DUSE_SYSTEM_ASSIMP=ON \
    -DUSE_SYSTEM_OPENEXR=ON \
    -DUSE_SYSTEM_EIGEN=ON \
    -DUSE_SYSTEM_GLFW=ON \
    -DUSE_SYSTEM_MAGNUM=ON \
    -DUSE_SYSTEM_PYBIND11=ON \
    -DUSE_SYSTEM_RAPIDJSON=ON \
    -DUSE_SYSTEM_BULLET=ON"

python -m pip install . -vv
