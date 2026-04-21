#!/bin/bash
mkdir build
cmake -S . -B build -G Ninja -DPython3_EXECUTABLE="$PYTHON" $CMAKE_ARGS
cmake --build build --config Release
