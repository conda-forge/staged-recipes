#!/usr/bin/env bash

set -eux

cd $SRC_DIR

make python-build

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

$PYTHON -m pip install $SRC_DIR/languages/python/oso
