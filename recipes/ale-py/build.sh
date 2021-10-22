#!/bin/bash

set -ex

mkdir build && cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
cmake --build . --target install