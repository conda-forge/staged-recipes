#!/usr/bin/env bash

set -euxo pipefail

export PATH="$BUILD_PREFIX/bin:$PATH"

NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

# install azurite globally from the npm registry
# all things coming after this are just concerned with generating the ThirdPartyLicenses.txt file
npm install -g ${PKG_NAME}@${PKG_VERSION} --omit=dev --ignore-scripts

# Let us use pnpm for licenses
cat <<< $(jq 'del(.packageManager)' package.json) > package.json

npm install --package-lock-only --omit=dev --ignore-scripts
pnpm import
pnpm install --prod --ignore-scripts
pnpm licenses list --json --prod | pnpm-licenses generate-disclaimer --json-input --output-file=ThirdPartyLicenses.txt