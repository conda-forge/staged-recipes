#!/bin/bash -e

if [ "$(uname)" = "Linux" ]; then
    python -m pip install . --no-deps --ignore-installed -vvv --install-option=--enable-gotcha
else
    python -m pip install . --no-deps --ignore-installed -vvv
fi
