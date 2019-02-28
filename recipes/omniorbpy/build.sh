#!/bin/bash

export CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++17/-std=c++14/g")

mkdir build
autoconf
cd build
../configure --prefix=$PREFIX \
             --with-openssl \
             --with-omniorb=${CONDA_PREFIX}
make -j$CPU_COUNT
make install

export PYTHONPATH=$PYTHONPATH:$PREFIX/lib/python${PY_VER}/site-packages
