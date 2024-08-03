#!/usr/bin/env bash
#
# Conda-forge recommended build recipe
set -euxo pipefail

pushd "${SRC_DIR}"/@dydxprotocol/v4-proto
  npm install --omit=dev --global "dydxprotocol-v4-proto-${PKG_VERSION}.tgz"
popd
