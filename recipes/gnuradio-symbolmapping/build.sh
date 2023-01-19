#!/usr/bin/env bash

mkdir build
cd build

cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DLIB_SUFFIX=""
    -DPYTHON_EXECUTABLE=$PYTHON
    -DENABLE_DOXYGEN=OFF
)

cmake ${CMAKE_ARGS} -G "Ninja" "${cmake_config_args[@]}" ..
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --target install
