#!/bin/bash

if [[ "$target_platform" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
