#!/bin/bash

# Downgrade the C++ standard because `throw` is no longer supported.
# We do this (instead of downgrading the compiler) to avoid any ABI compatibility issues.
# See:
# - https://github.com/conda/conda-build/issues/3097
# - https://stackoverflow.com/a/49119902/2427624
if [[ ${target_platform} =~ .*linux.* ]]; then
    CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++14}"
fi

# Regenerate the configure script since we're patching configure.ac.
autoreconf -if
# Explicitly specify BLAS and LAPACK libraries. Not necessary on Linux,
# but on macOS it links against the wrong libraries otherwise.
./configure --prefix=${PREFIX} --with-blas=blas --with-lapack=lapack
make
make check
make install
