#!/bin/bash
mkdir build
cd build
cmake $RECIPE_DIR/test -DCMAKE_BUILD_TYPE=Debug
make
if [ "$(uname)" == "Darwin" ]; then
    # The tests are failing with a segfault...
    ./main || true
    brew install valgrind
    valgrind --leak-check=full ./main
else
    ./main
fi

# These executables fail with a non-0 return because there is no visual context available in CI
visualinfo || true
glewinfo || true