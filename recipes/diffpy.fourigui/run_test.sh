#!/bin/bash

# Check if the OS is Linux
if [[ "$(uname)" == "Linux" ]]; then
    # Export display and start Xvfb only on Linux
    export DISPLAY=:99
    Xvfb :99 -screen 0 1024x768x16 &
    echo "Xvfb started and DISPLAY set for Linux"
fi

# Run pytest
pytest