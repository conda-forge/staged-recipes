#!/usr/bin/env bash

set -exuo pipefail

export npm_config_cache="${SRC_DIR}/.npm-cache"
npm pack --ignore-scripts --silent --pack-destination "${BUILD_PREFIX}"
npm install \
    --global \
    --ignore-scripts \
    --silent \
    --prefix "${PREFIX}/libexec/npm" \
    "${BUILD_PREFIX}/npm-${PKG_VERSION}.tgz"

mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/npm_activate.sh" "${PREFIX}/etc/conda/activate.d/npm.sh"
cp "${RECIPE_DIR}/npm_deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/npm.sh"
