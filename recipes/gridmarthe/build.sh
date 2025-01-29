#!/bin/bash

cd $SRC_DIR
mkdir -p build
# no-deps : already installed with conda, do not try hell...
$PYTHON -m pip install --no-deps -vvv . \
    -Cbuild-dir=build \
    -Csetup-args=-Dcondabuild=true \
    || (cat build/meson-logs/meson-log.txt && exit 1)

