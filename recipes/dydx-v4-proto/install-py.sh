#!/usr/bin/env bash

set -ex

# Install
cd v4-proto-py
  ${PYTHON} -m pip install . \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --prefix "${PREFIX}"
cd ..
touch "$RECIPE_DIR/ThirdPartyLicenses.txt"
