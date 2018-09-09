#! /bin/bash

export CXXFLAGS="-std=c++11"

cd Child/Code && mkdir _build && cd _build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="$CXXFLAGS -O3"
make -j$CPU_COUNT all
make -j$CPU_COUNT install
