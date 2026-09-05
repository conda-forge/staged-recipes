#!/usr/bin/env bash
set -euxo pipefail

# $CXX and the include/lib paths come from the test environment's compiler
# activation; -lblitz is what upstream's pkg-config advertises.
#
# These are flag STRINGS, not paths -- they must word-split.
# shellcheck disable=SC2086
${CXX} ${CXXFLAGS} ${CPPFLAGS} test_blitzpp.cpp -o test_blitzpp ${LDFLAGS} -lblitz
./test_blitzpp
