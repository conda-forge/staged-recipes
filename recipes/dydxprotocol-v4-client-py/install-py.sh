#!/usr/bin/env bash

set -ex

# Install
pushd v4-client-py-v2
  ${PYTHON} -m pip install . \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --prefix "${PREFIX}"
popd
