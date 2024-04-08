#!/usr/bin/env bash

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
