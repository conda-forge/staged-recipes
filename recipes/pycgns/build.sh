#!/bin/bash

export HDF5_DIR=${PREFIX}

python setup.py build

python setup.py install --prefix=${PREFIX}

