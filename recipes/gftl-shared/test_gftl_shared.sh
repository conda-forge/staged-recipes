#!/usr/bin/env bash
set -euxo pipefail

# Versioned subdir install ($PREFIX/GFTL_SHARED-<x.y>/). Assert the CMake package
# config and the Fortran modules landed. That this package built at all is the
# proof that find_package(GFTL) resolved the subdir-installed gFTL.
sub=$(echo "$PREFIX"/GFTL_SHARED-*)
test -d "$sub/include"
test -f "$sub/cmake/GFTL_SHAREDConfig.cmake"
echo "gFTL-shared installed at: $sub"
echo GFTL_SHARED_OK
