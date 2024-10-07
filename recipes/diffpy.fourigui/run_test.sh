#!/bin/bash
# Start Xvfb
XVFB_PID=$!
# Export display
export DISPLAY=:99
Xvfb :99 -screen 0 1280x1024x24 &

# Run pytest
pytest

# Clean up Xvfb
kill $XVFB_PID
