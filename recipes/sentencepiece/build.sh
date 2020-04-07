#!/bin/bash

export SENTENCEPIECE_HOME=${PREFIX}/sentencepiece
export PKG_CONFIG_PATH=${SENTENCEPIECE_HOME}/lib/pkgconfig

mkdir build && cd build

cmake -DCMAKE_INSTALL_PREFIX=${SENTENCEPIECE_HOME} ..
make -j4 && make install

cd ..
cd python

python setup.py install  --single-version-externally-managed --record=record.txt
