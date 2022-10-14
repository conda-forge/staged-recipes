#!/bin/sh

set -xe

cmake CMakeLists.txt -DCMAKE_INSTALL_PREFIX="$PREFIX" -DPython3_EXECUTABLE="$PYTHON" -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release
cmake --build .
cmake --install .
