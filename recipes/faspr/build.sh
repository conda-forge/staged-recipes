#!/usr/bin/env bash
set -euo pipefail

# Use -ffast-math on Linux; macOS clang uses -ffast-math as well (avoid --fast-math)
if [[ "$(uname)" == "Darwin" ]]; then
    FAST_MATH_FLAG="-ffast-math"
else
    FAST_MATH_FLAG="--fast-math"
fi

$CXX -O3 ${FAST_MATH_FLAG} -o FASPR src/*.cpp

# Install binary
install -m 755 -d "${PREFIX}/bin"
install -m 755 FASPR "${PREFIX}/bin/FASPR"
