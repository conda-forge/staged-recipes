#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    # Force C++14 for macOS to completely avoid char8_t issues
    export CXXFLAGS="${CXXFLAGS} -std=c++14"
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++14"
else
    # Use default settings for Linux (keep what's working)
    $PYTHON -m pip install . --no-deps -vv
fi
