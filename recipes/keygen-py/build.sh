#!/usr/bin/env bash

$PYTHON -m pip install . -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
