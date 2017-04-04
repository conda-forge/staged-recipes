#!/bin/bash

set -e
set -x

export UNIXODBC_INCLUDE_DIR=$CONDA_PREFIX/include
python setup.py install --single-version-externally-managed --record record.txt
