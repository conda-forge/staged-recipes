#!/bin/sh
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DEIGEN_SKIP_TESTS=ON ..
cmake --build . --target install --config Release
