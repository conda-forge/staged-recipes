#!/bin/sh

mkdir build && cd build

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DWITH_GUDHI_PYTHON=OFF \
  ..

# install include files and utils
make install -j${CPU_COUNT}

# install the python package
cmake -DWITH_GUDHI_PYTHON=ON .
cd cython
echo "**************************************************"
pwd
echo "**************************************************"
ls
echo "**************************************************"
$PYTHON setup.py install

