#!/bin/bash

#  Based on conda-forge recipe for scipy
export LIBRARY_PATH="${PREFIX}/lib"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    # Also, included a workaround so that `-stdlib=c++` doesn't go to
    # `gfortran` and cause problems.
    #
    # https://github.com/conda-forge/toolchain-feedstock/pull/8
    export CFLAGS="${CFLAGS} -stdlib=libc++ -lc++"
    export LDFLAGS="-headerpad_max_install_names -undefined dynamic_lookup -bundle -Wl,-search_paths_first -lc++"
else
    unset LDFLAGS
fi

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
