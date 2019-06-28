#!/bin/bash

# Downgrade the C++ standard because `throw` is no longer supported.
# We do this (instead of downgrading the compiler) to avoid any ABI compatibility issues.
# See:
# - https://github.com/conda/conda-build/issues/3097
# - https://stackoverflow.com/a/49119902/2427624
if [[ ${target_platform} =~ .*linux.* ]]; then
    CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++14}"
fi

./configure --prefix=${PREFIX}
make
make check  # For some reason this fails on BLAS ddot()
make install
