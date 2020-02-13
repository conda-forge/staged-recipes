#!/usr/bin/env sh

# Restore previous env vars if they were set.
unset CARTOPY_OFFLINE_SHARED
if [ -n "$_CONDA_SET_CARTOPY_OFFLINE_SHARED" ]; then
    export CARTOPY_OFFLINE_SHARED=$_CONDA_SET_CARTOPY_OFFLINE_SHARED
    unset _CONDA_SET_CARTOPY_OFFLINE_SHARED
fi
