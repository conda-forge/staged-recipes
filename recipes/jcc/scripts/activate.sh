#!/bin/bash

# Store existing env vars and set to this conda env
# so other installs don't pollute the environment.

if [[ -n "JCC_JDK" ]]; then
    export _JCC_JDK_CONDA_BACKUP=$JCC_JDK
fi

export JCC_JDK=$CONDA_PREFIX
