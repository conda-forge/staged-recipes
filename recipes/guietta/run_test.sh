#!/bin/sh

# Start a virtual framebuffer and import our module

if [ "$(uname)" == "Linux" ]; then
    xvfb-run -s '-screen 0 640x480x24' python -c "import guietta"
fi

