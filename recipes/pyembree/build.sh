#!/bin/bash
set -e
set -x

export C_INCLUDE_PATH="${PREFIX}/include:${C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="${PREFIX}/include:${CPLUS_INCLUDE_PATH}"

python setup.py install --prefix=$PREFIX
