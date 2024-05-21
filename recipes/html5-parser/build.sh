#!/usr/bin/env bash
set -eux

export CFLAGS="$CFLAGS -Wno-unused-but-set-variable"

# this is re-called inside `setup.py`, gives clearer errors outside
$PYTHON unix_build.py build
$PYTHON -m pip install -vv --no-deps --no-build-isolation .
