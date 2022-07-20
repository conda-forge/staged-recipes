#!/bin/bash -e

cd test

cmake -GNinja -DCMAKE_BUILD_TYPE=Release .

cmake --build . --config Release

./visit_struct_example
