#!/usr/bin/env bash
set -euxo pipefail

# Header/template library: the build step mostly stages generated templates, and
# install copies them plus the CMake package config into $PREFIX/GFTL-<x.y>/.
# The project is `LANGUAGES NONE`; its tests are guarded by check_language(Fortran)
# plus `find_package(PFUNIT 4.1 QUIET)`, neither of which is satisfied here, so
# they are skipped without asking. (gFTL never reads BUILD_TESTING, so passing it
# only earned an "unused variable" warning.)
#
# CMAKE_ARGS is a flag STRING from the compiler activation and must word-split; it
# is unset here because this build needs no compiler, hence the :- default.
# shellcheck disable=SC2086
cmake -G Ninja -S . -B build \
  ${CMAKE_ARGS:-} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX"

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build
