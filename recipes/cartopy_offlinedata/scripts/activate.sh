#!/usr/bin/env sh

# Store existing env vars and set to this conda env
# so other installs don't pollute the environment.

if [ -n "$CARTOPY_OFFLINE_SHARED" ]; then
    export _CONDA_SET_CARTOPY_OFFLINE_SHARED=$CARTOPY_OFFLINE_SHARED
fi


export CARTOPY_OFFLINE_SHARED=${CONDA_PREFIX}/share/cartopy
