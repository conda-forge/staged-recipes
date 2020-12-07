#!/bin/sh

# restore previous env vars is they were set
unset TEMPO2

if [ -n "$_CONDA_SET_TEMPO2" ]; then
    export TEMPO2=$_CONDA_SET_TEMPO2
    unset _CONDA_SET_TEMPO2
fi
