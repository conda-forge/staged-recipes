#!/usr/bin/env bash
export CLANG_BIN=$PREFIX/bin/clang

$CLANG_BIN --version

python -m pip install . -vv
