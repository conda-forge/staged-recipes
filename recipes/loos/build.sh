#!/bin/sh

set -xe

cmake CMakeLists.txt ${CMAKE_ARGS} -DPython3_EXECUTABLE="$PYTHON" -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release
cmake --build . -j ${CPU_COUNT}
cmake --install .
