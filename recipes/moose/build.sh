#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_FMT_USE_CHAR8_T=0 -fno-char8_t"
    # Use C++20 only for macOS
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++20"
else
    # Use default settings for Linux (keep what's working)
    $PYTHON -m pip install . --no-deps -vv
fi
