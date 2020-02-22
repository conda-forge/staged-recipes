#!/usr/bin/env bash

# Store existing neuralcoref env vars and set to this conda env
# so other neuralcoref installs don't pollute the environment

if [[ -n "$NEURALCOREF_CACHE" ]]; then
    export _CONDA_SET_NEURALCOREF_CACHE=$NEURALCOREF_CACHE
fi

export NEURALCOREF_CACHE=$CONDA_PREFIX/share/neuralcoref_cache
