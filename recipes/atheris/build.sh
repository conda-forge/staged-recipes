#!/usr/bin/env bash
set -eux
export CLANG_BIN=$PREFIX/bin/clang

$CLANG_BIN --version

python -m pip install . -vv
