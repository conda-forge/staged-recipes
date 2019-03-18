#!/usr/bin/env bash

export BLIS_COMPILER="$CC"
if [[ "$(uname)" == "Linux" ]]; then
    $PYTHON -m pip install . --no-deps -vv --global-option="build_ext" --global-option="-lrt"
else
    $PYTHON -m pip install . --no-deps -vv 
fi
