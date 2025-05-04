#!/bin/bash

mkdir build
cd build
cmake -DBUILD_PYTHON=OFF ..
cmake --build . -j $(nproc)

ctest -R MyTestForGlobal

cmake --install . --prefix "$PREFIX"
