#!/bin/bash

export UMFPACK="${PREFIX}/lib"

$PYTHON setup.py install --single-version-externally-managed --record record.txt
