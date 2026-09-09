#!/usr/bin/env bash
set -euxo pipefail

# Versioned subdir install ($PREFIX/FARGPARSE-<x.y>/). Assert the CMake package
# config, the Fortran modules and the static library landed. Building at all proves
# find_package(GFTL) and find_package(GFTL_SHARED) resolved across the subdir
# installs.
sub=$(echo "$PREFIX"/FARGPARSE-*)
test -d "$sub/include"
test -f "$sub/cmake/FARGPARSEConfig.cmake"
ls "$sub"/lib*/libfargparse.a
echo "fArgParse installed at: $sub"
echo FARGPARSE_OK
