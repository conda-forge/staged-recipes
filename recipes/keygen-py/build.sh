#!/usr/bin/env bash

maturin build --release

$PYTHON -m pip install target/wheels/keygen_py-*.whl

