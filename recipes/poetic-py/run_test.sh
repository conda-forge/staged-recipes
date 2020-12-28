#!/bin/sh

if [ "$(uname)" == "Linux" ]; then
    xvfb-run -s '-screen 0 640x480x24' python -c "import poetic"
fi