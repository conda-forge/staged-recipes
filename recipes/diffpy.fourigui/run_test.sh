#!/bin/bash
# Export display
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x16 &

# Run pytest
pytest

