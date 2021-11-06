#!/usr/bin/env bash

mkdir _build
cd _build
cmake ../dxtbx "-DCMAKE_INSTALL_PREFIX=$PREFIX" "-DPython_EXECUTABLE=$PYTHON"
cmake --build .
cmake --install .
pip install ../dxtbx