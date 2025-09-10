#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_FMT_USE_CHAR8_T=0 -fno-char8_t"
    # Force C++17 for macOS due to compatibility issues with C++20
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++17"
else
    # Use default settings for Linux (keep what's working)
    $PYTHON -m pip install . --no-deps -vv
fi
