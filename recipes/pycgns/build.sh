#!/bin/bash

export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"

python setup.py build

python setup.py install --prefix=${PREFIX}
