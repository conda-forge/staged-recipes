#!/bin/bash
mkdir build
cd build
cmake $RECIPE_DIR -DCMAKE_BUILD_TYPE=Debug
make
./main || true