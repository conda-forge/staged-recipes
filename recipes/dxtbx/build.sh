#!/usr/bin/env bash

mkdir _build
cd _build
cmake ../dxtbx "-DCMAKE_INSTALL_PREFIX=$PREFIX" "-DPython_EXECUTABLE=$PYTHON" -GNinja
cmake --build .
cmake --install .
$PYTHON -mpip install ../dxtbx
