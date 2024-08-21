#!/usr/bin/env bash

set -ex

# Install
pushd "${SRC_DIR}"/bindings/python
  ${PYTHON} -m pip install . \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --prefix "${PREFIX}"
popd
