#! /bin/bash

args=("$@")
is_c=true

for arg in "$@"; do
    if [[ $arg == *".cpp" || $arg == *".cc" ]]; then
        is_c=false
    fi
done

new_args=$(basename "$0")

for arg in "$@"; do
    if [[ ($arg == "-std=c++11") && $is_c == true  ]]; then
        new_args=("${new_args[@]}" "-std=c99")
    else
        new_args=("${new_args[@]}" "$arg")
    fi
done

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IFS=':' read -ra env_path <<< "$PATH"
PATH=""
for dir in "${env_path[@]}"; do
    if [[ "$dir" != "$SCRIPT_DIR" ]]; then
        PATH="${PATH:+$PATH:}$dir"
    fi
done

export PATH
exec "${new_args[@]}"
