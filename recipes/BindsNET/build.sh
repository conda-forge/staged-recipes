#!/bin/bash

set -e -v


conda install -n base --no-deps -q -y -c conda-forge torchvision >=0.3.0
conda install -n base --no-deps -q -y -c conda-forge tensorboardx >=1.7
conda install -n base --no-deps -q -y -c hcc gym

# $PYTHON -m pip install foolbox>=2.4.0

# $PYTHON setup.py install
# $PYTHON -m pip install --no-deps . -vv
$PYTHON -m pip install . -vv