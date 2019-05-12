#!/usr/bin/env bash

set -x
set -e

cp -r ocean landice visualization mesh_tools conda_package

cd conda_package
${PYTHON} -m pip install . --no-deps -vv

cd mesh_tools/mesh_conversion_tools

# build and install JIGSAW
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release ..
make
make install

