#! /bin/bash

mkdir _build && cd _build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j$CPU_COUNT all
make -j$CPU_COUNT install
