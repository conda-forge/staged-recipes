#!/bin/bash
set -ex

# macOS-specific fix for char8_t issue in fmt
if [[ "$(uname)" == "Darwin" ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_FMT_USE_CHAR8_T=0 -fno-char8_t"
fi

$PYTHON -m pip install . --no-deps -vv

