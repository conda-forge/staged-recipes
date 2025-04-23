#!/bin/bash
set -xeo pipefail

export SKIP_YASM_BUILD=true
export CFLAGS="${CFLAGS/-flto/}"
export CXXFLAGS="${CXXFLAGS/-flto/}"

python -m pip install . -vv