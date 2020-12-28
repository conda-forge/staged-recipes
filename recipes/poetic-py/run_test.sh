#!/bin/sh

if [ "$(uname)" == "Linux" ]; then
    xvfb-run python -c "import poetic"
fi