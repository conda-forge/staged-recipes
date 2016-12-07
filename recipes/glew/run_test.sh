#!/bin/bash
mkdir build
cd build
cmake $RECIPE_DIR/test -DCMAKE_BUILD_TYPE=Debug
make
./main

# These executables fail with a non-0 return because there is no visual context available in CI
visualinfo || true
glewinfo || true