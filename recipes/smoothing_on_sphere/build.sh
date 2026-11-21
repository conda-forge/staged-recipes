#!/usr/bin/env bash
set -euo pipefail

# Use the activated conda-forge compiler wrappers, including their sysroot flags.
"${CC:?Clang C compiler was not activated}" --version | grep -i clang
"${CXX:?Clang C++ compiler was not activated}" --version | grep -i clang

export LIBOMP_PREFIX="$PREFIX"
export SMOOTHING_OPENMP_RUNTIME=llvm
export PIP_NO_INDEX=1

test -f "$LIBOMP_PREFIX/include/omp.h"
case "$(uname -s)" in
    Linux) test -f "$LIBOMP_PREFIX/lib/libomp.so" ;;
    Darwin) test -f "$LIBOMP_PREFIX/lib/libomp.dylib" ;;
    *) echo "Unsupported Unix platform" >&2; exit 1 ;;
esac

"$PYTHON" -m pip install . -vv --no-deps --no-build-isolation
