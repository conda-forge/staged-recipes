#!/usr/bin/env bash

set -ex

cargo-bundle-licenses --format yaml --output THIRDPARTY.yaml
python -m pip install . \
    --no-deps --ignore-installed -vv --no-build-isolation --disable-pip-version-check
