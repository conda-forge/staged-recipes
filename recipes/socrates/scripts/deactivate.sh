#!/bin/sh

unset RAD_DIR
unset RAD_BIN
unset RAD_DATA
unset RAD_SCRIPT
unset LOCK_FILE

if [ -z "$_CONDA_SET_RAD_DIR" ]; then
    export RAD_DIR=$_CONDA_SET_RAD_DIR
    unset _CONDA_SET_RAD_DIR
fi
if [ -z "$_CONDA_SET_RAD_BIN" ]; then
    export RAD_BIN=$_CONDA_SET_RAD_BIN
    unset _CONDA_SET_RAD_BIN
fi
if [ -z "$_CONDA_SET_RAD_DATA" ]; then
    export RAD_DATA=$_CONDA_SET_RAD_DATA
    unset _CONDA_SET_RAD_DATA
fi
if [ -z "$_CONDA_SET_RAD_SCRIPT" ]; then
    export RAD_SCRIPT=$_CONDA_SET_RAD_SCRIPT
    unset _CONDA_SET_RAD_SCRIPT
fi
if [ -z "$_CONDA_SET_LOCK_FILE" ]; then
    export LOCK_FILE=$_CONDA_SET_LOCK_FILE
    unset _CONDA_SET_LOCK_FILE
fi
