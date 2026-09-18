#!/bin/bash

set -exo pipefail

# prevent puppeteer from downloading chromium
export PUPPETEER_SKIP_DOWNLOAD=1

npm install -g --prefix="${PREFIX}" "@mermaid-js/mermaid-cli@${PKG_VERSION}"

find "${PREFIX}" -name "*.bare" -delete
find "${PREFIX}" -name "prebuilds" -type d -exec rm -rf {} +

# remove native napi canvas binary
rm -rf "${PREFIX}/lib/node_modules/@mermaid-js/mermaid-cli/node_modules/@napi-rs"

# generate a third-party license disclaimer for the bundled node_modules
pnpm install --prod --ignore-scripts
pnpm licenses list --prod --json | pnpm-licenses generate-disclaimer --prod --json-input --output-file="${SRC_DIR}/third-party-licenses.txt"
