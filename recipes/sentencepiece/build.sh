#!/bin/bash

export SENTENCEPIECE_HOME=${PREFIX}/lib/sentencepiece
export PKG_CONFIG_PATH=${SENTENCEPIECE_HOME}

# mkdir build && cd build
#
# cmake -DCMAKE_INSTALL_PREFIX=${SENTENCEPIECE_HOME} ..
# make -j4 && make install
#
# cd ..
cd python

python setup.py install  --single-version-externally-managed --record=record.txt
