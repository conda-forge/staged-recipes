#!/usr/bin/env bash

set -ex

# Install with verbose output
${PYTHON} -m pip install "${SRC_DIR}"/wheels/${PKG_NAME}-${PKG_VERSION}-*.whl \
  --no-build-isolation \
  --no-deps \
  --only-binary :all: \
  --verbose \
  --prefix "${PREFIX}"

# Verify the installation: files installed
ls -la "${PREFIX}"/lib/python*/site-packages/${PKG_NAME}*.egg-info
${PYTHON} -c "import ${PKG_NAME}; print(${PKG_NAME}.__version__)"
