#! /usr/bin/env bash

set -euxo pipefail

# Set a few environment variables that are not set due to
# https://github.com/conda/conda-build/issues/3993
export PIP_NO_BUILD_ISOLATION=True
export PIP_NO_DEPENDENCIES=True
export PIP_IGNORE_INSTALLED=True
export PIP_NO_INDEX=True
export PYTHONDONTWRITEBYTECODE=True

# Install
$PYTHON -m pip \
  --only-binary=:all: \
  --no-deps \
  --no-index \
  --find-links $SRC_DIR/wheelhouse ${PKG_NAME}==${PKG_VERSION}
