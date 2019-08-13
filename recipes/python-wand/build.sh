#!/usr/bin/env bash

if [ `uname -s` == "Darwin" ]; then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

export MAGICK_HOME="${PREFIX}"

$PYTHON -m pip install . --no-deps --ignore-installed -vvv
