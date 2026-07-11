#!/usr/bin/env bash
set -ex

# Ensure flag configurations respect Conda's environment configurations
export CFLAGS="${CFLAGS}"
export CXXFLAGS="${CXXFLAGS}"
export FFLAGS="${FFLAGS}"

${PYTHON} -m build --no-isolation --verbose -Csetup-args=-Dfvsvariants=${ variants } -Csetup-args=-Dbuildtype=${ mode }