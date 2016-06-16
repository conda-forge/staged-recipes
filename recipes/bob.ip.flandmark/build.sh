#!/usr/bin/env bash

source activate "${CONDA_DEFAULT_ENV}"

export CFLAGS="${CFLAGS} -pthread"
export LDFLAGS="${LDFLAGS} -lpthread"

$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
