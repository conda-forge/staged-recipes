#!/bin/sh
mkdir build && cd build
cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=RELEASE  -DSPICEQL_BUILD_DOCS=OFF -DSPICEQL_BUILD_TESTS=OFF  -DPython3_EXECUTABLE=$PYTHON  ..
cmake --build . --config RELEASE
cmake --install . --config RELEASE
