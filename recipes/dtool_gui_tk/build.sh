#!/bin/bash
if [ "$(uname)" == "Linux" ]; then
    export DISPLAY=:1
fi

python -m pip install . -vv
