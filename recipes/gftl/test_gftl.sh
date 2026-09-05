#!/usr/bin/env bash
set -euxo pipefail

# gFTL installs into a versioned subdir ($PREFIX/GFTL-<x.y>/), so the standard
# package_contents include/lib matchers do not apply -- assert the templates and
# the CMake package config landed there. The real proof that find_package(GFTL)
# resolves is that gftl-shared builds against this package.
sub=$(echo "$PREFIX"/GFTL-*)
test -d "$sub/include"
test -f "$sub/cmake/GFTLConfig.cmake"
echo "GFTL installed at: $sub"
echo GFTL_OK
