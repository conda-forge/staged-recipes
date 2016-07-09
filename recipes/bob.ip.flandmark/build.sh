#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

if [[ `uname` == 'Darwin' ]]; then
    export CPPFLAGS="${CPPFLAGS} -DBOOST_NO_CXX11_RVALUE_REFERENCES"
fi

export CFLAGS="${CFLAGS} -pthread"
export LDFLAGS="${LDFLAGS} -lpthread"

$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
