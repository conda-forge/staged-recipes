#!/bin/sh

if [ -z "$RAD_DIR" ]; then
    export _CONDA_SET_RAD_DIR=$RAD_DIR
fi
if [ -z "$RAD_BIN" ]; then
    export _CONDA_SET_RAD_BIN=$RAD_BIN
fi
if [ -z "$RAD_DATA" ]; then
    export _CONDA_SET_RAD_DATA=$RAD_DATA
fi
if [ -z "$RAD_SCRIPT" ]; then
    export _CONDA_SET_RAD_SCRIPT=$RAD_SCRIPT
fi
if [ -z "$LOCK_FILE" ]; then
    export _CONDA_SET_LOCK_FILE=$LOCK_FILE
fi

export RAD_DIR="$CONDA_PREFIX"/share/socrates
export RAD_BIN="$RAD_DIR"/bin
export RAD_DATA="$RAD_DIR"/data
export RAD_SCRIPT="$RAD_DIR"/sbin
export LOCK_FILE="radiation_code.lock"
