#!/usr/bin/env bash
set -exo pipefail

# Create license report for dependencies
pnpm install --prod --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Install globally
pnpm pack --config.ignore-scripts=true
npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --ignore-scripts \
    ${PKG_NAME}-${PKG_VERSION}.tgz
