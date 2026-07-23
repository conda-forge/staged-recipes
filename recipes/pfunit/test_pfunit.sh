#!/usr/bin/env bash
set -euxo pipefail

# Versioned subdir install ($PREFIX/PFUNIT-<x.y>/). Assert the CMake package config
# and the static libraries LFRic links (-lpfunit -lfunit) landed, plus the .pf
# preprocessor consumers invoke. Building at all proves find_package resolved the
# gftl/gftl-shared/fargparse subdir installs and that MPI was found.
sub=$(echo "$PREFIX"/PFUNIT-*)
test -d "$sub/include"
test -f "$sub/cmake/PFUNITConfig.cmake"
ls "$sub"/lib*/libpfunit.a
ls "$sub"/lib*/libfunit.a
# The .pf preprocessor lands under the subdir's bin.
ls "$sub"/bin/funitproc 2>/dev/null || ls "$sub"/bin/pFUnitParser.py 2>/dev/null || {
  echo "ERROR: pFUnit .pf preprocessor not found under $sub/bin"; ls "$sub/bin" || true; exit 1; }
echo "pFUnit installed at: $sub"
echo PFUNIT_OK
