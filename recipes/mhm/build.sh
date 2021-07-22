#!/bin/bash
export FC=$(basename ${FC})
cmake -DCMAKE_BUILD_TYPE=Release -B build -S .
cmake --build build --parallel
cmake --install build --prefix $PREFIX
