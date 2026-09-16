#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# elkjs declares no npm dependencies, so there is nothing to vendor at install time. The
# third-party code it does carry is already baked into the lib/ bundles, and its licences
# ship from the recipe directory (see THIRD-PARTY-NOTICES.md). Packing and installing the
# published tarball is enough.
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    "${SRC_DIR}/elkjs-${PKG_VERSION}.tgz"
