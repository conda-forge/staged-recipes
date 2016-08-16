#!/bin/bash

export BZIP2_DIR=$PREFIX
export HDF5_DIR=$PREFIX
export LZO_DIR=$PREFIX

$PYTHON setup.py install --single-version-externally-managed --record record.txt
