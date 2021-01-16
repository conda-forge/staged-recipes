#!/bin/sh

# restore previous env vars is they were set
unset PSRCHIVE

if [ -n "$_CONDA_SET_PSRCHIVE" ]; then
    export PSRCHIVE=$_CONDA_SET_PSRCHIVE
    unset _CONDA_SET_PSRCHIVE
fi
