#!/bin/bash
set -euo pipefail

# Workaround for ldas-tools-al 2.6.x headers using std::binary_function,
# which was removed in C++17. This define re-enables it in libc++.
export CXXFLAGS="${CXXFLAGS:-} -D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION"

python -m pip install . -vv --no-deps --no-build-isolation
