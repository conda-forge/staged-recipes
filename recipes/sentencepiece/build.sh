#!/bin/bash

cd python

export SENTENCEPIECE_HOME=${PREFIX}/lib/sentencepiece
export PKG_CONFIG_PATH=${SENTENCEPIECE_HOME}/lib/pkgconfig

python -m pip install . -vv
