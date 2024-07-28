#!/usr/bin/env bash
#
# Conda-forge recommended build recipe
set -euxo pipefail

pushd v4-proto-js
  npm install -global "${PKG_NAME}-${PKG_VERSION}.tgz"
popd
