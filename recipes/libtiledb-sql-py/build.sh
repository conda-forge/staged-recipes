#!/bin/bash

set -e
set -x

$PYTHON setup.py install --single-version-externally-managed --record record.txt
