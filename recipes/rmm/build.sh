#!/usr/bin/env bash

export INSTALL_PREFIX=${CONDA_PREFIX}

export LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH

cd ${SRC_DIR}/rmm/python

$PYTHON setup.py build_ext --inplace
$PYTHON setup.py install
