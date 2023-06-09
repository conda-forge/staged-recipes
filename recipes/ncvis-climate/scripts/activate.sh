#!/usr/bin/env sh

# Store existing env vars and set to this conda env
# so other installs don't pollute the environment.

if [ -n "$NCVIS_RESOURCE_DIR" ]; then
    export _CONDA_SET_NCVIS_RESOURCE_DIR=$NCVIS_RESOURCE_DIR
fi


export NCVIS_RESOURCE_DIR=${CONDA_PREFIX}/share/ncvis/resources