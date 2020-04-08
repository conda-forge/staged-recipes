#!/bin/bash

export SENTENCEPIECE_HOME=${PREFIX}/lib/sentencepiece
export PKG_CONFIG_PATH=${SENTENCEPIECE_HOME}/lib/pkgconfig

python -m pip install . -vv

cd ..
cd python

python setup.py install  --single-version-externally-managed --record=record.txt
