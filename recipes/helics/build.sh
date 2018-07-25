#!/bin/bash

set -e
set -x


if [ `uname` = "Darwin" ]; then
	FLAGS="-std=c++14"
else
	FLAGS="-std=c++11"
fi

mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=$FLAGS -DBUILD_PYTHON_INTERFACE=ON -DCMAKE_INSTALL_PREFIX=$PREFIX ../
make -j $CPU_COUNT
make install

