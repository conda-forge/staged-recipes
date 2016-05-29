#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"
export MACOSX_DEPLOYMENT_TARGET=10.9

python setup.py install --symengine-dir=$PREFIX
