#!/bin/bash

$PYTHON -m pip install git+https://github.com/stgl/pymcc
$PYTHON setup.py --quiet install --single-version-externally-managed --record=record.txt
