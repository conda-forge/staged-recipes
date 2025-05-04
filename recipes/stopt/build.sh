#!/bin/bash

mkdir build
cd build
cmake -DBUILD_PYTHON=OFF ..
cmake --build . --config Release -j $(nproc)

ctest -R MyTestForGlobal

cmake --install . --prefix "$PREFIX"
