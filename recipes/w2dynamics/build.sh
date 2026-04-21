#!/bin/bash
mkdir build
cmake -S . -B build -DPython3_EXECUTABLE="$PYTHON" $CMAKE_ARGS
cmake --build build --config Release
