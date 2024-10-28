#!/usr/bin/env bash

maturin build

$PYTHON -m pip install target/wheels/keygen_py-*.whl

