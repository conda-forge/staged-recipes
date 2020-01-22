#!/bin/bash
export CPLUS_INCLUDE_PATH=src/ice/bzip2
$PYTHON -m pip install . --no-deps --ignore-installed -vv
