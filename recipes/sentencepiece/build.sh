#!/bin/bash

# mkdir build && cd build
#
# cmake -DCMAKE_INSTALL_PREFIX=${SENTENCEPIECE_HOME} ..
# make -j4 && make install
#
# cd ..
cd python

export SENTENCEPIECE_HOME=${PREFIX}/lib/sentencepiece
export PKG_CONFIG_PATH=${SENTENCEPIECE_HOME}/lib/pkgconfig

# python setup.py build
# python setup.py install

python -m pip install . -vv
