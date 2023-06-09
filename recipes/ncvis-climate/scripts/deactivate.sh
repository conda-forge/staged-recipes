#!/usr/bin/env sh

# Restore previous env vars if they were set.
unset NCVIS_RESOURCE_DIR
if [ -n "$_CONDA_SET_NCVIS_RESOURCE_DIR" ]; then
    export NCVIS_RESOURCE_DIR=$_CONDA_SET_NCVIS_RESOURCE_DIR
    unset _CONDA_SET_NCVIS_RESOURCE_DIR
fi