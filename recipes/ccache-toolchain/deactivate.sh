#!/bin/bash

unset CCACHE_DIR

# Read PATH and split by : to array env_path
IFS=':' read -ra env_path <<< "$PATH"

PATH=""
for dir in "${env_path[@]}"; do
    if [[ $dir != "${PREFIX}/bin/conda_forge_ccache" ]]; then
        PATH="${PATH:+$PATH:}$dir"
    fi
done

export PATH

# Print statistics for diagnosing
ccache -s
