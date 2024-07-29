#!/usr/bin/env bash
#
# Conda-forge recommended build recipe
set -euxo pipefail

pushd @dydyprotocol/v4-proto
  npm install --prod --global "${PKG_NAME}-${PKG_VERSION}.tgz"
popd
