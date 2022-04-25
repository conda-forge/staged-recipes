#!/usr/bin/env bash

mkdir _build
cd _build
cmake ../dials \
    "${CMAKE_ARGS}" \
    "-DCMAKE_INSTALL_PREFIX=$PREFIX" \
    "-DPython_EXECUTABLE=$PYTHON" \
    -DCMAKE_BUILD_TYPE=Release \
    -GNinja
cmake --build .
cmake --install .
$PYTHON -mpip install ../dials
