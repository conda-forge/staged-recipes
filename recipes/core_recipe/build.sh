#!/bin/bash
export ISISROOT=$PWD
mkdir build && cd build
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DISIS_BUILD_SWIG=ON -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX -DPython3_EXECUTABLE="$PYTHON" ../isis/src/core
cmake --build . --config RELEASE
cmake --install . --config RELEASE
