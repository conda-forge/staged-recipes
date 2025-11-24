#!/bin/sh

# Provide hint to CMake's find_package routine
# regarding location of LauraConfig.cmake
export LAURA_ROOT="${CONDA_PREFIX}/share/Laura++"
