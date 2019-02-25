#!/usr/bin/env bash

export BLIS_COMPILER="$CC"
$PYTHON -m pip install . --no-deps -vv
