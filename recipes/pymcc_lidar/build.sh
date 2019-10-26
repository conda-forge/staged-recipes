#!/bin/bash

export PYTHON_EXECUTABLE=$PYTHON

$PYTHON setup.py --quiet install --single-version-externally-managed --record=record.txt
