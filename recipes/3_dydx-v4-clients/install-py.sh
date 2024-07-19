#!/usr/bin/env bash

set -ex

# Install
cd v4-clients-py-v2
  ${PYTHON} -m pip install . \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --prefix "${PREFIX}"
cd ..
touch "$RECIPE_DIR/ThirdPartyLicenses.txt"
