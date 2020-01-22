#!/usr/bin/env bash
set -evx

export MAKEFLAGS="-j2"

rm pyproject.toml
python -m pip install . -vv

