#!/bin/bash

set -e
set -x


if [ `uname` = "Darwin" ]; then
	FLAGS="-std=c++14"
else
	FLAGS="-std=c++11"
fi

if [[ $PY3K -eq 1 || $PY3K == "True" ]]; then
  BUILD_PYTHON="-DBUILD_PYTHON_INTERFACE=ON"
else
  BUILD_PYTHON="-DBUILD_PYTHON2_INTERFACE=ON"
fi

mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=$FLAGS ${BUILD_PYTHON} -DCMAKE_INSTALL_PREFIX=$PREFIX ../
make -j $CPU_COUNT
make install

cp -v ${PREFIX}/python/_helics.so ${SP_DIR}/
cp -v ${PREFIX}/python/helics.py ${SP_DIR}/
