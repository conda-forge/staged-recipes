#!/bin/bash
# Restore previous env vars if any
export MAGPLUS_HOME=

if [ -z "$_CONDA_SET_MAGPLUS_HOME" ]; then
    export MAGPLUS_HOME=$_CONDA_SET_MAGPLUS_HOME
    export _CONDA_SET_MAGPLUS_HOME=
fi
