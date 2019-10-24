#!/bin/bash

export PYTHON_EXECUTABLE=$CONDA_PYTHON_EXE

$PYTHON setup.py --quiet install --single-version-externally-managed --record=record.txt
