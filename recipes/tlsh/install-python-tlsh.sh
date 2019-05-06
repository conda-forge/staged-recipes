#!/usr/bin/env bash
set -eux
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
cd "${SRC_DIR}/py_ext"
python setup.py install --prefix=$PREFIX
