#!/usr/bin/env bash

if [ `uname -s` == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

export MAGICK_HOME="${PREFIX}/"
export PATH=${PREFIX}/bin/:$PATH

$PYTHON -m pip install . --no-deps --ignore-installed -vvv
