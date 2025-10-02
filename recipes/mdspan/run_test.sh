#!/bin/bash
set -ex

# Build the test program
cd tests
cmake -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    .

cmake --build .

# Run the test program
./test_mdspan
