#!/usr/bin/env bash
set -evx

export MAKEFLAGS="-j2"

rm pyproject.toml || echo "Already removed pyproject file"
python -m pip install . -vv

