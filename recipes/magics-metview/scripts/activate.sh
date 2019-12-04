#!/bin/bash
# Store existing env vars so we can restore them later
if [ -z "$MAGPLUS_HOME" ]; then
    export _CONDA_SET_MAGPLUS_HOME=$MAGPLUS_HOME
fi

export MAGPLUS_HOME=$CONDA_PREFIX
