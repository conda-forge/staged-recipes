#!/usr/bin/env bash

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DFMJPEG2K=${PREFIX} ..

cmake --build . --target install --parallel
