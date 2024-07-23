#!/usr/bin/env bash

set -euxo pipefail

# Don't use pre-built gyp packages
export npm_config_build_from_source=true

pnpm install --save-dev @types/jest
pnpm run build
# Audit fails for the latest request version
# pnpm audit fix

pnpm install
pnpm pack
pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file="$SRC_DIR"/ThirdPartyLicenses.txt

npm install -g "dydxprotocol-node-service-base-dev-${PKG_VERSION}.tgz"
