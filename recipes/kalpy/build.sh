#!/bin/bash
set -ex

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
$PYTHON -m pip install . --no-deps -vv