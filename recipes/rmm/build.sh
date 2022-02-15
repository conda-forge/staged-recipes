#!/usr/bin/env bash

export INSTALL_PREFIX=${CONDA_PREFIX}

cd ${SRC_DIR}/rmm/python

$PYTHON setup.py build_ext --inplace
$PYTHON setup.py install
