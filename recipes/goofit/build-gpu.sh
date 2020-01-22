#!/usr/bin/env bash
set -evx

export CFLAGS="${CFLAGS} -I/usr/include"
export CXXFLAGS="${CXXFLAGS} -I/usr/include"

rm pyproject.toml
python -m pip install . -vv

