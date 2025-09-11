#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    # Force C++11 for macOS
    export CXXFLAGS="${CXXFLAGS} -std=c++11"
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++11"
else
    # Use default settings for Linux (keep what's working)
    $PYTHON -m pip install . --no-deps -vv
fi
