#!/bin/sh

# store existing TEMPO2 vars

if [ -n "$TEMPO2" ]; then
    export _CONDA_SET_TEMPO2=$TEMPO2
fi

export TEMPO2=${CONDA_PREFIX}/share/tempo2
