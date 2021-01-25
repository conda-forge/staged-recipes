#!/bin/sh

# store existing PSRCHIVE vars

if [ -n "$PSRCHIVE" ]; then
    export _CONDA_SET_PSRCHIVE=$PSRCHIVE
fi

export PSRCHIVE=${CONDA_PREFIX}
