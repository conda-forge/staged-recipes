#!/bin/bash
if [ "$(uname)" == "Linux" ]; then
    export DISPLAY=localhost:1.0
fi

python -m pip install . -vv
