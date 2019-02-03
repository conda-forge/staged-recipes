#!/bin/bash

# avoid absolute-paths in compilers following example of
# https://github.com/conda-forge/mpich-feedstock/pull/26
export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")
