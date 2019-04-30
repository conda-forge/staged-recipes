#!/bin/bash

unset ISCE_HOME
if [[ -n "$_CONDA_SET_ISCE_HOME" ]]; then
    export ISCE_HOME=$_CONDA_SET_ISCE_HOME
    unset _CONDA_SET_ISCE_HOME
fi

unset ISCE_STACK
if [[ -n "$_CONDA_SET_ISCE_STACK" ]]; then
    export ISCE_STACK=$_CONDA_SET_ISCE_STACK
    unset _CONDA_SET_ISCE_STACK
fi

