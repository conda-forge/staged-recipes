#!/usr/bin/env bash

$PYTHON unix_build.py
$PYTHON -m pip install \
    -vv \
    --no-deps \
    --no-build-isolation \
    --find-links=dist \
    --no-index \
    html5-parser
