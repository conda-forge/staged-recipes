#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# elkjs declares no dependencies, so there is nothing to vendor and no third-party
# licence report to generate: packing and installing the published tarball is enough.
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    "${SRC_DIR}/elkjs-${PKG_VERSION}.tgz"
