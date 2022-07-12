#!/usr/bin/env bash

set -eux

cd $SRC_DIR

make python-build

$PYTHON -m pip install $SRC_DIR/languages/python/oso