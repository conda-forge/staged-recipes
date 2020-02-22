#!/usr/bin/env bash
# Restore previous neuralcoref env vars if they were set

unset NEURALCOREF_CACHE
if [[ -n "$_CONDA_SET_NEURALCOREF_CACHE" ]]; then
    export NEURALCOREF_CACHE=$_CONDA_SET_NEURALCOREF_CACHE
    unset _CONDA_SET_NEURALCOREF_CACHE
fi
