#!/usr/bin/env bash

set -e

./configure.py --enable-shared

$PYTHON -m pip install . -vv
