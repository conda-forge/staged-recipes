#!/bin/bash

export USE_OMP=1

$PYTHON setup.py install --single-version-externally-managed --record record.txt
