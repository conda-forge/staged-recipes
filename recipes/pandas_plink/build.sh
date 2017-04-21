#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

$PYTHON setup.py install --single-version-externally-managed --record record.txt
