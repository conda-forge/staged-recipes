#!/bin/bash

export HDF5_DIR=$PREFIX
export BZIP2_DIR=$PREFIX
export LZO_DIR=$PREFIX

$PYTHON setup.py install
