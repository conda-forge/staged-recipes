#!/usr/bin/env bash

set -ex

# Install
${PYTHON} -m pip install "${SRC_DIR}"/wheels/${PKG_NAME}-${PKG_VERSION}-*.whl \
  --no-build-isolation \
  --no-deps \
  --only-binary :all: \
  --prefix "${PREFIX}"
